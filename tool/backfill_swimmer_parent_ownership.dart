import 'dart:convert';
import 'dart:io';

const swimmersCollection = 'swimmers';
const usersCollection = 'users';

const fieldEmail = 'email';
const fieldRole = 'role';
const fieldParentUid = 'parentUid';
const fieldUpdatedAt = 'updatedAt';

const parentEmailCandidateFields = [
  'parentEmail',
  'parent_email',
  'guardianEmail',
  'guardian_email',
  fieldEmail,
];

Future<void> main(List<String> args) async {
  final options = CliOptions.parse(args);
  if (options.showHelp) {
    stdout.writeln(CliOptions.usage);
    return;
  }

  if (options.projectId == null || options.projectId!.trim().isEmpty) {
    stderr.writeln('Missing --project-id.');
    stderr.writeln(CliOptions.usage);
    exitCode = 64;
    return;
  }

  final token = await options.resolveAccessToken();
  if (token == null || token.trim().isEmpty) {
    stderr.writeln(
      'Missing access token. Use --access-token, FIRESTORE_ACCESS_TOKEN, '
      'or --use-gcloud-token.',
    );
    exitCode = 64;
    return;
  }

  final client = FirestoreRestClient(
    projectId: options.projectId!,
    accessToken: token,
  );

  final swimmers = await client.listCollection(swimmersCollection);
  final users = await client.listCollection(usersCollection);

  final parentsByEmail = <String, List<FirestoreDoc>>{};
  for (final user in users) {
    if (user.stringField(fieldRole) != 'parent') continue;
    final email = normalize(user.stringField(fieldEmail));
    if (email == null) continue;
    parentsByEmail.putIfAbsent(email, () => []).add(user);
  }

  final summary = BackfillSummary(totalSwimmers: swimmers.length);
  final updates = <BackfillUpdate>[];

  for (final swimmer in swimmers) {
    if (hasText(swimmer.stringField(fieldParentUid))) {
      summary.alreadyHasParentUid++;
      continue;
    }

    final identifier = resolveParentIdentifier(swimmer);
    if (identifier == null) {
      summary.missingParentIdentifier++;
      summary.manualReview.add(
        '${swimmer.shortName}: no usable parent email field',
      );
      continue;
    }

    final matches = parentsByEmail[identifier.email] ?? const [];
    if (matches.isEmpty) {
      summary.missingParentUser++;
      summary.manualReview.add(
        '${swimmer.shortName}: no parent user for ${identifier.field} '
        '"${identifier.email}"',
      );
      continue;
    }

    if (matches.length > 1) {
      summary.ambiguousParentMatches++;
      summary.manualReview.add(
        '${swimmer.shortName}: multiple parent users for ${identifier.field} '
        '"${identifier.email}"',
      );
      continue;
    }

    summary.uniquelyMatched++;
    updates.add(
      BackfillUpdate(
        swimmer: swimmer,
        parentUid: matches.single.id,
        sourceField: identifier.field,
        sourceEmail: identifier.email,
      ),
    );
  }

  summary.wouldUpdate = updates.length;
  printSummary(summary, options.apply);

  if (!options.apply) {
    stdout.writeln('');
    stdout.writeln('Dry run only. Re-run with --apply to update safe matches.');
    return;
  }

  for (final update in updates) {
    if (hasText(update.swimmer.stringField(fieldParentUid))) {
      stdout.writeln('Skipped ${update.swimmer.shortName}: parentUid exists');
      continue;
    }

    await client.patchDocument(
      update.swimmer,
      {
        fieldParentUid: firestoreString(update.parentUid),
        fieldUpdatedAt: firestoreTimestamp(DateTime.now().toUtc()),
      },
      const [fieldParentUid, fieldUpdatedAt],
    );
    stdout.writeln(
      'Updated ${update.swimmer.shortName} from ${update.sourceField} '
      '"${update.sourceEmail}"',
    );
  }
}

ParentIdentifier? resolveParentIdentifier(FirestoreDoc swimmer) {
  for (final field in parentEmailCandidateFields) {
    final email = normalize(swimmer.stringField(field));
    if (email != null) {
      return ParentIdentifier(field: field, email: email);
    }
  }
  return null;
}

void printSummary(BackfillSummary summary, bool apply) {
  stdout.writeln(
    'Swimmer parent ownership backfill ${apply ? 'APPLY' : 'DRY RUN'}',
  );
  stdout.writeln('total swimmers scanned: ${summary.totalSwimmers}');
  stdout.writeln('already has parentUid: ${summary.alreadyHasParentUid}');
  stdout.writeln('uniquely matched: ${summary.uniquelyMatched}');
  stdout.writeln(
    'ambiguous parent matches: ${summary.ambiguousParentMatches}',
  );
  stdout.writeln(
    'missing parent identifier: ${summary.missingParentIdentifier}',
  );
  stdout.writeln('missing parent user: ${summary.missingParentUser}');
  stdout.writeln('would-update: ${summary.wouldUpdate}');

  if (summary.manualReview.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('Manual review:');
    for (final item in summary.manualReview) {
      stdout.writeln('- $item');
    }
  }
}

bool hasText(String? value) => value != null && value.trim().isNotEmpty;

String? normalize(String? value) {
  final text = value?.trim().toLowerCase();
  if (text == null || text.isEmpty) return null;
  return text;
}

Map<String, Object?> firestoreString(String value) => {'stringValue': value};

Map<String, Object?> firestoreTimestamp(DateTime value) => {
      'timestampValue': value.toIso8601String(),
    };

class CliOptions {
  const CliOptions({
    required this.apply,
    required this.showHelp,
    this.projectId,
    this.accessToken,
    this.useGcloudToken = false,
  });

  final bool apply;
  final bool showHelp;
  final String? projectId;
  final String? accessToken;
  final bool useGcloudToken;

  static CliOptions parse(List<String> args) {
    var apply = false;
    var showHelp = false;
    var useGcloudToken = false;
    String? projectId;
    String? accessToken;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '--apply':
          apply = true;
        case '--help':
        case '-h':
          showHelp = true;
        case '--use-gcloud-token':
          useGcloudToken = true;
        case '--project-id':
          projectId = _readValue(args, ++i, arg);
        case '--access-token':
          accessToken = _readValue(args, ++i, arg);
        default:
          if (arg.startsWith('--project-id=')) {
            projectId = arg.substring('--project-id='.length);
          } else if (arg.startsWith('--access-token=')) {
            accessToken = arg.substring('--access-token='.length);
          } else {
            throw FormatException('Unknown argument: $arg');
          }
      }
    }

    return CliOptions(
      apply: apply,
      showHelp: showHelp,
      projectId: projectId,
      accessToken: accessToken,
      useGcloudToken: useGcloudToken,
    );
  }

  Future<String?> resolveAccessToken() async {
    if (hasText(accessToken)) return accessToken;
    final envToken = Platform.environment['FIRESTORE_ACCESS_TOKEN'];
    if (hasText(envToken)) return envToken;
    if (!useGcloudToken) return null;

    final result = await Process.run(
      'gcloud',
      const ['auth', 'application-default', 'print-access-token'],
      runInShell: true,
    );
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      return null;
    }
    return result.stdout.toString().trim();
  }

  static String _readValue(List<String> args, int index, String flag) {
    if (index >= args.length) {
      throw FormatException('Missing value for $flag');
    }
    return args[index];
  }

  static const usage = '''
Usage:
  dart run tool/backfill_swimmer_parent_ownership.dart --project-id PROJECT_ID [--access-token TOKEN]
  dart run tool/backfill_swimmer_parent_ownership.dart --project-id PROJECT_ID --use-gcloud-token
  dart run tool/backfill_swimmer_parent_ownership.dart --project-id PROJECT_ID --apply --use-gcloud-token

Default mode is dry-run. Writes require --apply.
''';
}

class FirestoreRestClient {
  FirestoreRestClient({
    required this.projectId,
    required this.accessToken,
  });

  final String projectId;
  final String accessToken;

  final HttpClient _http = HttpClient();

  Uri _documentsUri(String collection, [Map<String, String>? query]) {
    return Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$projectId/databases/(default)/documents/$collection',
      query,
    );
  }

  Future<List<FirestoreDoc>> listCollection(String collection) async {
    final docs = <FirestoreDoc>[];
    String? pageToken;

    do {
      final query = <String, String>{'pageSize': '300'};
      if (pageToken != null) query['pageToken'] = pageToken;

      final response = await _getJson(_documentsUri(collection, query));
      final documents = response['documents'] as List<dynamic>? ?? const [];
      docs.addAll(
        documents
            .cast<Map<String, dynamic>>()
            .map((json) => FirestoreDoc.fromJson(json)),
      );
      pageToken = response['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);

    return docs;
  }

  Future<void> patchDocument(
    FirestoreDoc doc,
    Map<String, Object?> fields,
    List<String> updateMask,
  ) async {
    final maskQuery = updateMask
        .map((field) =>
            'updateMask.fieldPaths=${Uri.encodeQueryComponent(field)}')
        .join('&');
    final uri = Uri(
      scheme: 'https',
      host: 'firestore.googleapis.com',
      path: '/v1/${doc.name}',
      query: maskQuery,
    );

    final request = await _http.patchUrl(uri);
    _addHeaders(request);
    request.write(jsonEncode({'fields': fields}));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'PATCH failed ${response.statusCode}: $body',
        uri: uri,
      );
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final request = await _http.getUrl(uri);
    _addHeaders(request);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'GET failed ${response.statusCode}: $body',
        uri: uri,
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  void _addHeaders(HttpClientRequest request) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  }
}

class FirestoreDoc {
  const FirestoreDoc({
    required this.name,
    required this.fields,
  });

  factory FirestoreDoc.fromJson(Map<String, dynamic> json) {
    return FirestoreDoc(
      name: json['name'] as String,
      fields: (json['fields'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, decodeFirestoreValue(value)),
      ),
    );
  }

  final String name;
  final Map<String, Object?> fields;

  String get id => name.split('/').last;

  String get shortName {
    final parts = name.split('/');
    if (parts.length < 2) return name;
    return '${parts[parts.length - 2]}/${parts.last}';
  }

  String? stringField(String field) {
    final value = fields[field];
    return value?.toString();
  }
}

Object? decodeFirestoreValue(Object? value) {
  if (value is! Map<String, dynamic>) return null;
  if (value.containsKey('stringValue')) return value['stringValue'];
  if (value.containsKey('integerValue')) return value['integerValue'];
  if (value.containsKey('doubleValue')) return value['doubleValue'];
  if (value.containsKey('booleanValue')) return value['booleanValue'];
  if (value.containsKey('timestampValue')) return value['timestampValue'];
  if (value.containsKey('nullValue')) return null;
  return value;
}

class ParentIdentifier {
  const ParentIdentifier({
    required this.field,
    required this.email,
  });

  final String field;
  final String email;
}

class BackfillUpdate {
  const BackfillUpdate({
    required this.swimmer,
    required this.parentUid,
    required this.sourceField,
    required this.sourceEmail,
  });

  final FirestoreDoc swimmer;
  final String parentUid;
  final String sourceField;
  final String sourceEmail;
}

class BackfillSummary {
  BackfillSummary({required this.totalSwimmers});

  final int totalSwimmers;
  int alreadyHasParentUid = 0;
  int uniquelyMatched = 0;
  int ambiguousParentMatches = 0;
  int missingParentIdentifier = 0;
  int missingParentUser = 0;
  int wouldUpdate = 0;
  final List<String> manualReview = [];
}
