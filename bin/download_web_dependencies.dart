import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// This small utility allows to download the dependencies required to use Beerstory web.
Future<void> main() async {
  await _downloadDependency('simolus3/sqlite3.dart', 'sqlite3.wasm');
  await _downloadDependency('simolus3/drift', 'drift_worker.js');
}

/// Downloads a dependency.
Future<bool> _downloadDependency(String repo, String filename) async {
  try {
    File sqlite3File = File('./web/$filename');
    if (!sqlite3File.existsSync()) {
      stderr.writeln('Downloading $filename...');
      http.Response response = await http.get(Uri.https('api.github.com', '/repos/$repo/releases'));
      List assets = jsonDecode(response.body).first['assets'];
      String downloadUrl = assets.firstWhere((asset) => asset['name'] == filename)['browser_download_url'];
      response = await http.get(Uri.parse(downloadUrl));
      sqlite3File.writeAsBytesSync(response.bodyBytes);
    }
    stderr.writeln('$filename downloaded.');
    return true;
  } catch (ex, stacktrace) {
    stderr.writeln('Error while downloading $filename : $ex');
    stderr.writeln(stacktrace);
    return false;
  }
}
