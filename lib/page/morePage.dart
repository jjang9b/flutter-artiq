import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/guidePage.dart';
import 'package:artiq/sql/sqlLite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class MorePage extends StatefulWidget {
  static const routeName = '/more';

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  EdgeInsets moreMargin = const EdgeInsets.only(left: 30, right: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 56.0),
              child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.09,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(30, 20, 0, 0),
                            alignment: Alignment.topLeft,
                            child: Text("더보기",
                                style: TextStyle(
                                    fontSize: 23, fontFamily: "UTOIMAGE")),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.78,
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 0, 30, 5),
                                child: Text("버전",
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: "UTOIMAGE")),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text("v ${ArtiqData.version}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Arita")),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 30, 30, 5),
                                child: Text("설정",
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: "UTOIMAGE")),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("MUSIC 탭",
                                    style: TextStyle(
                                        fontSize: 15, fontFamily: "UTOIMAGE")),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text("다음 포스트 자동 재생",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Arita")),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 48,
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
                                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text("다음 포스트 랜덤 재생",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Arita")),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 48,
                                      margin: EdgeInsets.only(left: 20),
                                      child: Switch(
                                        value: ArtiqData.isMusicRandom,
                                        onChanged: (value) {
                                          setState(() {
                                            ArtiqData.isMusicRandom = value;
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
                                margin: EdgeInsets.fromLTRB(30, 10, 30, 5),
                                child: Text("안내",
                                    style: TextStyle(
                                        fontSize: 15, fontFamily: "UTOIMAGE")),
                              ),
                              Container(
                                height: 48,
                                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: InkWell(
                                  onTap: () {
                                    SqlLite().delete("guide");

                                    Navigator.pushNamedAndRemoveUntil(context,
                                        GuidePage.routeName, (_) => false);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text("오늘 하루 안내 보지 않기 초기화",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: "Arita")),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, top: 13),
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.refresh,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 30, 30, 5),
                                child: Text("포스트 추천 및 문의",
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: "UTOIMAGE")),
                              ),
                              Container(
                                height: 48,
                                margin:
                                    const EdgeInsets.fromLTRB(30, 10, 30, 10),
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
                                        child: Text("메일 보내기",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: "Arita")),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, top: 12),
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.email,
                                                size: 20,
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
                        Func.getNavigator(context)
                      ],
                    );
                  },
                  itemCount: 1),
            ),
          ],
        ),
      ),
    );
  }
}
