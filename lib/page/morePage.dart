import 'dart:async';

import 'package:artiq/data/artiqData.dart';
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
      backgroundColor: Color(0xff2B2B2B),
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
                              width: MediaQuery.of(context).size.width * 0.09,
                              margin: const EdgeInsets.fromLTRB(22, 10, 30, 5),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Func.goPage(context, PostPage.routeName);
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Color(0xffffffff),
                                  size: 30,
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.075,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                alignment: Alignment.topCenter,
                                child: Text("more.title",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
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
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.version",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child: Text("${ArtiqData.version}",
                                            style: GoogleFonts.notoSans(
                                                textStyle: TextStyle(
                                              fontSize: 16,
                                              color: ArtiqData.greyPinkColor,
                                            )))),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 30,
                                endIndent: 30,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.setting",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(30, 5, 20, 5),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child: Text("more.settingIsFavorite",
                                            style: GoogleFonts.notoSans(
                                                textStyle: TextStyle(
                                              fontSize: 16,
                                              color: ArtiqData.greyPinkColor,
                                            ))).tr()),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Container(
                                      width: 60,
                                      child: InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: Switch(
                                          value: ArtiqData.isFavoriteMusic,
                                          onChanged: (value) {
                                            setState(() {
                                              ArtiqData.isFavoriteMusic = value;

                                              Func.insertIsFavorite(value);
                                            });

                                            message = "more.settingSuccess";
                                            isMessage = true;

                                            Timer.periodic(Duration(milliseconds: 2000), (timer) {
                                              timer.cancel();

                                              isMessage = false;
                                              setState(() {});
                                            });
                                          },
                                          inactiveTrackColor: Color(0xffffffff),
                                          activeColor: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child: Text("more.settingFavoriteInit",
                                            style: GoogleFonts.notoSans(
                                                textStyle: TextStyle(
                                              fontSize: 16,
                                              color: ArtiqData.greyPinkColor,
                                            ))).tr()),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Container(
                                      width: 35,
                                      height: 35,
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
                                          color: ArtiqData.greyPinkColor,
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
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Text("more.mailTitle",
                                        style: GoogleFonts.notoSans(
                                            textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 16, fontWeight: FontWeight.bold)))
                                    .tr(),
                              ),
                              Container(
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child: Text("more.mailSend",
                                            style: GoogleFonts.notoSans(
                                                textStyle: TextStyle(
                                              fontSize: 16,
                                              color: ArtiqData.greyPinkColor,
                                            ))).tr()),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Container(
                                      width: 35,
                                      height: 35,
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
                                          color: ArtiqData.greyPinkColor,
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
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: 250,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
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
