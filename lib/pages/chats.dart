import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geminilocal/pages/chat.dart';
import 'package:geminilocal/pages/settings/model.dart';
import 'package:geminilocal/pages/settings/resources.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../engine.dart';
import 'support/elements.dart';
import 'package:intl/intl.dart';


class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});
  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {

  String formatDurationToShortString(DateTime currentTime, DateTime pastTimestamp) {
    final Duration difference = currentTime.difference(pastTimestamp);

    final int seconds = difference.inSeconds.abs();
    final int minutes = difference.inMinutes.abs();
    final int hours = difference.inHours.abs();
    final int days = difference.inDays.abs();

    if (seconds < 60) {
      return 'just now';
    } else if (minutes < 60) {
      final String unit = minutes == 1 ? 'minute' : 'minutes';
      return '$minutes $unit';
    } else if (hours < 24) {
      final String unit = hours == 1 ? 'hour' : 'hours';
      return '$hours $unit';
    } else if (days < 30) { // Approximates within a month
      final String unit = days == 1 ? 'day' : 'days';
      return '$days $unit';
    } else if (days < 365) {
      final int months = (days / 30).round();
      final String unit = months == 1 ? 'month' : 'months';
      return '$months $unit';
    } else {
      final int years = (days / 365).round();
      final String unit = years == 1 ? 'year' : 'years';
      return '$years $unit';
    }
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              Cards cards = Cards(context: context);
              return Consumer<AIEngine>(builder: (context, engine, child) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add_rounded),
                    tooltip: engine.dict.value("start_chat"),
                    onPressed: (){
                      engine.currentChat = "0";
                      engine.context.clear();
                      engine.contextSize = 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                  ),
                  body: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar.large(
                        surfaceTintColor: Colors.transparent,
                        leading: Padding(
                          padding: EdgeInsetsGeometry.only(left: 5),
                          child: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_rounded)
                          ),
                        ),
                        title: Text(engine.dict.value("chats")),
                        pinned: true,
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            divider.settings(
                                title: engine.dict.value("your_chats"),
                                context: context
                            ),
                            cards.cardGroup(
                                engine.chats.keys.toList().map((key){
                                  Map chat = engine.chats[key]??{
                                    "name": "Nonameyet",
                                    "history": {},
                                    "created": DateTime.now().millisecondsSinceEpoch.toString(),
                                    "updated": DateTime.now().millisecondsSinceEpoch.toString()
                                  };
                                  return CardContents.tap(
                                      title: chat["name"]??"Loading...",
                                      subtitle: formatDurationToShortString(DateTime.now(), DateTime.fromMillisecondsSinceEpoch(int.parse(chat["updated"]))) == "just now"
                                        ? engine.dict.value("just_now")
                                        : engine.dict.value(formatDurationToShortString(DateTime.now(), DateTime.fromMillisecondsSinceEpoch(int.parse(chat["updated"]))).split(" ")[1]).replaceAll("%time%", formatDurationToShortString(DateTime.now(), DateTime.fromMillisecondsSinceEpoch(int.parse(chat["updated"]))).split(" ")[0]),
                                      action: () async {
                                        print("I have chats: ${engine.chats.keys}");
                                        engine.isLoading = false;
                                        engine.context.clear();
                                        engine.contextSize = 0;
                                        engine.context = jsonDecode(chat["history"]);
                                        engine.currentChat = key;
                                        print("Loading chat $key: $chat");
                                        print("Context: ${engine.context}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ChatPage()),
                                        );
                                      }
                                  );
                                }).toList().cast<Widget>()
                            )
                          ],
                        ),
                      ),
                    ],

                  ),
                );
              });
            }
        )
    );
  }
}