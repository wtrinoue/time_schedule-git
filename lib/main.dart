import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:device_preview/device_preview.dart';
import 'package:time_schedule/schedule.dart';
import 'home_page.dart';
import 'sql.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // test();
  // test2();
  const app = MaterialApp(useInheritedMediaQuery: true, home: MyApp());
  if (kIsWeb) {
    final devicePreview = DevicePreview(builder: (_) => app);
    runApp(devicePreview);
  } else {
    runApp(app);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

/*
「今後付け加えたいこと」
・数字入力をテンキー入力にする。
・時刻入力をGoogleのTimePickerDialogを使用してできるようにする。
・JSONファイルに保存して複数予定を登録できるようにする
・永続化マイグレーションを利用してアプリを閉じてもひらけるようにする。
・BottomNvigationBarを利用して複数の予定を切り替えられるようにする。
・間に予定を入れられるようにする
 */

/*
今の課題
sqfliteがうまく使えない
 */
