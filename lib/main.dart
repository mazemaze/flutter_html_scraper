import 'package:flutter/material.dart';
import 'package:universal_html/driver.dart' as driver;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> result = [];
  List widgets = [];
  int paging = 1;
  bool loading = false;
  String urls = "";
  TextEditingController urlController = TextEditingController();

  Future<void> _load() async {
    if (urls == null || urls == "") {
      return null;
    }
    if (loading) {
      return null;
    }
    loading = true;
    try {
      var client = driver.HtmlDriver();
      var url = '${urls}?p=${paging}';
      await client
          .setDocumentFromUri(Uri.parse(url))
          .onError((error, stackTrace) => Container());
      var itemLists = client.document.querySelectorAll('.entry-title > a');
      setState(() {
        paging += 1;
      });
      for (int i = 0; i < itemLists.length; i++) {
        final title = itemLists[i].text;
        final link = itemLists[i].getAttribute("href");
        if (title.toLowerCase() != "tweet") {
          result.add(
            {
              'title': title,
              'link': link,
            },
          );
        }
      }
    } finally {
      loading = false;
    }
  }

  @override
  void initState() {
    super.initState();

    print(result);
  }

  Widget build(BuildContext context) {
    var length = result?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return SimpleDialog(
                    contentPadding: EdgeInsets.all(50),
                    title: Text("Urlを入力"),
                    children: [
                      Container(
                        child: Column(
                          children: [
                            TextField(
                              autofocus: false,
                              controller: urlController,
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      urls = urlController.text;
                                      urlController.text = "";
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text("追加"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("キャンセル"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == length) {
              _load();
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  width: 32.0,
                  height: 32.0,
                  child: const CircularProgressIndicator(),
                ),
              );
            } else if (index > length) {
              return null;
            }
            return ListTile(
              title: Text(
                result[index]['title'],
              ),
              subtitle: Text(
                result[index]['link'],
              ),
            );
          },
        ),
      ),
    );
  }
}
