import 'dart:async';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/postPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_fonts/google_fonts.dart';

class MorePage extends StatefulWidget {
  static const routeName = '/more';

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  EdgeInsets moreMargin = const EdgeInsets.only(left: 30, right: 15);
  bool isMessage = false;
  String message = "more.settingDefault";

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
                        Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(25, 15, 30, 5),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Func.goPage(context, PostPage.routeName);
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.075,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                alignment: Alignment.topCenter,
                                child: Text("more.title",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.78,
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.version",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 10),
                                child: Row(
                                  children: <Widget>[
                                    Container(child: Text("v ${ArtiqData.version}", style: GoogleFonts.notoSans(textStyle: TextStyle(fontSize: 16)))),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 30,
                                endIndent: 30,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.setting",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child:
                                            Text("more.settingFriendlyInit", style: GoogleFonts.notoSans(textStyle: TextStyle(fontSize: 16))).tr()),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Container(
                                      child: InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          Func.initGenre();

                                          message = "more.settingSuccess";
                                          isMessage = true;
                                          ArtiqData.likeGenre = "";
                                          setState(() {});

                                          Timer.periodic(Duration(milliseconds: 2000), (timer) {
                                            timer.cancel();

                                            isMessage = false;
                                            setState(() {});
                                          });
                                        },
                                        child: Icon(
                                          Icons.cached,
                                          size: 26,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 30,
                                endIndent: 30,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.mailTitle",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                                child: Row(
                                  children: <Widget>[
                                    Container(child: Text("more.mailSend", style: GoogleFonts.notoSans(textStyle: TextStyle(fontSize: 16))).tr()),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Container(
                                      child: InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          Email email = Email(
                                            subject: "more.mailSubject".tr(),
                                            recipients: ['bbplayworld@gmail.com'],
                                            isHTML: false,
                                          );

                                          FlutterEmailSender.send(email);
                                        },
                                        child: Icon(
                                          Icons.mail_outline,
                                          size: 26,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: 1),
            ),
            Positioned.fill(
              bottom: 20,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  opacity: isMessage ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    width: 250,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(message, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.white, fontSize: 13))).tr(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
