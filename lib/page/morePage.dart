import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class MorePage extends StatefulWidget {
  static const routeName = '/more';

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  Func func = new Func();
  EdgeInsets moreMargin = EdgeInsets.fromLTRB(28, 10, 15, 10);
  double moreHeight = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(28, 20, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Text("더보기",
                        style: TextStyle(fontSize: 23, fontFamily: "UTOIMAGE")),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.78,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: moreMargin,
                        child: Text("버전",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "UTOIMAGE")),
                      ),
                      Container(
                        height: moreHeight,
                        margin: moreMargin,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text("v ${ArtiqData.version}",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Arita")),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: moreMargin,
                        child: Text("설정",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "UTOIMAGE")),
                      ),
                      Container(
                        height: moreHeight,
                        margin: moreMargin,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text("MUSIC탭 다음 포스트 자동 재생",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Arita")),
                            ),
                            Container(
                              width: 60,
                              margin: EdgeInsets.only(left: 20),
                              child: Switch(
                                value: ArtiqData.isMusicAuto,
                                onChanged: (value) {
                                  setState(() {
                                    ArtiqData.isMusicAuto = value;
                                  });
                                },
                                inactiveTrackColor: Colors.black54,
                                activeColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: moreMargin,
                        child: Text("포스트 추천 및 문의",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "UTOIMAGE")),
                      ),
                      Container(
                        height: moreHeight,
                        margin: moreMargin,
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            Email email = Email(
                              subject: '[ArtiQ] 문의',
                              recipients: ['bbplayworld@gmail.com'],
                              isHTML: false,
                            );

                            FlutterEmailSender.send(email);
                          },
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text("bbplayworld@gmail.com",
                                    style: TextStyle(
                                        fontSize: 16, fontFamily: "Arita")),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.email,
                                        size: 27,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                func.getNavigator(context)
              ],
            )
          ],
        ),
      ),
    );
  }
}
