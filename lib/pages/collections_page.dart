import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycms/objects/app.dart';
import '../utils/utils.dart';
import 'package:readmore/readmore.dart';

class CollectionsPage extends StatefulWidget {
  final App app;

  const CollectionsPage({Key? key, required this.app}) : super(key: key);

  @override
  _CollectionsPageState createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage>
    with TickerProviderStateMixin {
  late App app;
  Map collections = {};
  late TabController tabController;
  bool showSearch = false;
  String search = "";

  int currIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 0, vsync: this, initialIndex: 0);
    app = widget.app;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Utils.appCollections.containsKey(app.id)) {
        setState(() {
          collections = Utils.appCollections[app.id];
          tabController = TabController(
              length: collections.length, vsync: this, initialIndex: 0);
        });
      } else {
        getCollections("all");
      }
    });
  }

  static Future<Map> process(args) async {
    App app = args["app"];
    Map cols = args["cols"];
    if (app.id == "tictrac") {

    }
    return cols;
  }

  getCollections(String collection) async {
    Map? cols = collections;
    for (var i in app.collections) {
      if(i!=collection && collection!="all") {
        continue;
      }
      Utils.showLoadingDialog(context, "Loading ${i}");
      print("${app.serverPath}${app.apis["getCollection"]}");
      var re = await compute(Utils.httpPost, {
        "domain": app.serverDomain,
        "path": "${app.serverPath}${app.apis["getCollection"]}",
        "body": {"collection": i, "limit": "-1"},
        "headers": {"Content-Type": "application/json"}
      });
      if (re != null) {
        cols ??= {};
        cols[i] = re;
      } else {
        break;
      }
      Navigator.pop(context);
    }
    Utils.showLoadingDialog(context, "Processing..");
    if (cols != null) {
      collections = await compute(process, {"app": app, "cols": cols});
      Utils.appCollections[app.id] = collections;
      tabController = TabController(
          length: collections.length, vsync: this, initialIndex: currIndex);
    }
    setState(() {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        actions: [
          TextButton.icon(
              onPressed: () {
                getCollections(app.collections[tabController.index]);
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Reload   "))
        ],
        bottom: TabBar(
            isScrollable: true,
            controller: tabController,
            tabs: List.generate(collections.length, (bi) {
              String key = collections.keys.elementAt(bi);
              return Tab(
                child: badges.Badge(
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.square,
                      badgeColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    badgeContent: Text(
                      "${collections[key].length}",
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                    child: Text(key.toUpperCase())),
              );
            })),
      ),
      body: TabBarView(
          controller: tabController,
          children: List<Widget>.generate(collections.length, (vi) {
            List col = collections.values.elementAt(vi);
            return CollectionList(
              collection: col,
              search: tabController.index == vi ? search.toLowerCase() : "",
              onUIDTap: (value) {
                if (app.id == "tictrac") {
                  var user = collections["users"].firstWhere((us) => us["uid"] == value)??{};
                  return user;
                }
              },
            );
          })),
      bottomSheet: MyBottomAppBar(
        sort: () async {
          if (await sort() != null) {
            setState(() {});
          }
        },
        onSearchChanged: (v) {
          setState(() {
            search = v;
          });
        },
      ),
    );
  }

  sort() async {
    var currCollection = collections.values.elementAt(tabController.index);
    List keys = currCollection[0]
        .keys
        .toList()
        .where((key) =>
    (currCollection[0][key].runtimeType == String ||
        currCollection[0][key].runtimeType == int ||
        currCollection[0][key].runtimeType == double))
        .toList();
    String key = keys[0];
    int sorting = 1;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDState) =>
              SimpleDialog(
                contentPadding: const EdgeInsets.all(16),
                title: const Text("Sort"),
                children: [
                  DropdownButton<String>(
                    items: List.generate(
                        keys.length,
                            (index) =>
                            DropdownMenuItem(
                              value: keys[index],
                              child: Text("${keys[index]}"),
                            )),
                    onChanged: (value) {
                      setDState(() {
                        key = value!;
                      });
                    },
                    value: key,
                    isExpanded: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                              onTap: () {
                                setDState(() {
                                  sorting = 1;
                                });
                              },
                              child: const Center(child: Text("Ascending")))),
                      Switch(
                          value: sorting == 1 ? false : true,
                          onChanged: (v) {
                            sorting = v ? -1 : 1;
                            setDState(() {});
                          }),
                      Expanded(
                          child: InkWell(
                              onTap: () {
                                setDState(() {
                                  sorting = -1;
                                });
                              },
                              child: const Center(child: Text("Descending")))),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        currCollection.sort((a, b) =>
                        (sorting == 1
                            ? (a[key].toString().compareTo(b[key].toString()))
                            : (b[key].toString().compareTo(
                            a[key].toString()))));
                        Navigator.pop(context, true);
                      },
                      child: const Text("Sort"))
                ],
              ),
        );
      },
    );
  }
}

class CollectionList extends StatefulWidget {
  final String search;
  final List collection;
  final Function onUIDTap;

  const CollectionList({super.key,
    this.search = "",
    required this.collection,
    required this.onUIDTap});

  @override
  State<CollectionList> createState() => _CollectionListState();
}

class _CollectionListState extends State<CollectionList> {
  copy(text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"), duration: const Duration(milliseconds: 100),));
  }

  mapToWidget(doc) {
    var keys = doc.keys.toList();
    return Container(
      color: Colors.yellow,
      padding: const EdgeInsets.all(8),
      child: Table(
          columnWidths: const {
            0: FractionColumnWidth(1 / 4),
            1: FractionColumnWidth(3 / 4),
          },
          children: List<TableRow>.generate(
            keys.length,
                (ki) {
              var k = keys.elementAt(ki);
              if (k == "__v") {
                return TableRow(children: [Container(), Container()]);
              }
              var value = doc[k];
              Widget keyWidget = Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text("$k: ", style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600),)),
              );
              Widget valueWidget = Container();
              if (value.runtimeType == String ||
                  value.runtimeType == bool ||
                  value.runtimeType == int ||
                  value.runtimeType == double) {
                if (value.runtimeType == int &&
                    ["start", "last_updated", "created", "updated"]
                        .contains(k)) {
                  valueWidget = valueWidget = InkWell(
                    onLongPress: () {
                      copy("$value");
                    },
                    child: ReadMoreText(
                      Utils.formattedDateTime(value),
                      style: const TextStyle(color: Colors.black),
                      trimMode: TrimMode.Line,
                      trimLength: 1,
                      trimCollapsedText: "more",
                      trimExpandedText: "less",
                    ),
                  );
                } else if (["uid", "user_id"].contains(k)) {
                  valueWidget = valueWidget = InkWell(
                    onLongPress: () {
                      copy("$value");
                    },
                    onTap: () {
                      var user = widget.onUIDTap("$value");
                      showDialog(context: context,
                        builder: (context) {
                          return AlertDialog(
                              backgroundColor: Colors.transparent,
                              content: mapToWidget(user));
                        },);
                    },
                    child: ReadMoreText(
                      "$value",
                      style: const TextStyle(color: Colors.black),
                      trimMode: TrimMode.Line,
                      trimLength: 2,
                      trimCollapsedText: "more",
                      trimExpandedText: "less",
                    ),
                  );
                } else {
                  valueWidget = valueWidget = InkWell(
                    onLongPress: () {
                      copy("$value");
                    },
                    child: ReadMoreText(
                      "$value",
                      style: const TextStyle(color: Colors.black),
                      trimMode: TrimMode.Line,
                      trimLength: 2,
                      trimCollapsedText: "more",
                      trimExpandedText: "less",
                    ),
                  );
                }
              } else if (value.runtimeType == List) {
                if (value.length == 0) value = [""];
                if (value[0].runtimeType == String ||
                    value[0].runtimeType == int ||
                    value[0].runtimeType == List ||
                    value[0].runtimeType == double) {
                  String t = "${value[0]}";
                  for (int v = 1; v < value.length; v++) {
                    t += ", ${value[v]}";
                  }
                  valueWidget = InkWell(
                    onLongPress: () {
                      copy("$value");
                    },
                    child: ReadMoreText(
                      t,
                      style: const TextStyle(color: Colors.black),
                      trimMode: TrimMode.Line,
                      trimLength: 2,
                      trimCollapsedText: "more",
                      trimExpandedText: "less",
                    ),
                  );
                } else if (value[0].runtimeType == Map) {
                  valueWidget = mapToWidget(value);
                }
              }
              else if (value.runtimeType.toString().contains("Map<")) {
                valueWidget = InkWell(
                  onLongPress: () {
                    copy("$value");
                  },
                  onTap: () {
                    showDialog(context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.transparent,
                          scrollable: true,
                          content: mapToWidget(value));
                      },);
                  },
                  child: Text(
                    "${value.toString().substring(0, 10)} ..more",
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              } else {
                valueWidget = InkWell(
                  onLongPress: () {
                    copy("$value");
                  },
                  child: ReadMoreText(
                    "$value",
                    style: const TextStyle(color: Colors.black),
                    trimMode: TrimMode.Line,
                    trimLength: 2,
                    trimCollapsedText: "more",
                    trimExpandedText: "less",
                  ),
                );
              }

              return TableRow(decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.2))), children: [
                keyWidget,
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                  child: valueWidget,
                ),
              ]);
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.collection.length,
      itemBuilder: (context, i) {
        Map doc = widget.collection[i];
        return doc.toString().toLowerCase().contains(widget.search)
            ? Padding(
            padding: EdgeInsets.only(
                bottom: ((widget.collection.length - 1 == i) ? 400 : 2)),
            child: mapToWidget(doc))
            : Container(
          height: widget.collection.length == (i - 1) ? 400 : 0,
        );
      },
    );
  }
}

class MyBottomAppBar extends StatefulWidget {
  final sort, onSearchChanged;

  const MyBottomAppBar({Key? key, this.sort, this.onSearchChanged})
      : super(key: key);

  @override
  _MyBottomAppBarState createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  bool showSearch = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            // color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              )),
          // width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list),
                          label: const Text("Filter"))),
                  Expanded(
                      child: TextButton.icon(
                          onPressed: widget.sort,
                          icon: const Icon(Icons.sort),
                          label: const Text("Sort"))),
                  Expanded(
                      child: TextButton.icon(
                          onPressed: () async {
                            setState(() {
                              showSearch = !showSearch;
                              print(showSearch);
                            });
                          },
                          icon: const Icon(Icons.search),
                          label: const Text("Search"))),
                ],
              ),
              if (showSearch)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(maxHeight: showSearch ? 50 : 0),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: widget.onSearchChanged,
                      decoration: InputDecoration(
                          hintText: "Search",
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          suffix: InkWell(
                            onTap: () {
                              searchController.clear();
                              widget.onSearchChanged("");
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 16,
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      onClosing: () {},
    );
  }
}
