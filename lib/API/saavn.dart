import 'dart:convert';

import 'package:des_plugin/des_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List searchedList = [];
String kUrl = "", checker, image, title, album, artist, lyrics, has_320, rawkUrl;
String key = "38346591";
String decrypt = "";

Future<List> fetchSongsList(searchQuery) async {
  String searchUrl = "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&query=" + searchQuery + "&__call=autocomplete.get";
  var res = await http.get(searchUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  searchedList = getMain["songs"]["data"];

  return searchedList;
}

Future fetchSongDetails(songId) async {
  String songUrl = "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&__call=song.getDetails&pids=" + songId;
  var res = await http.get(songUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  title = (getMain[songId]["title"]).toString().split("(")[0].replaceAll("&amp;", "&").replaceAll("&#039;", "'").replaceAll("&quot;", "\"");
  image = (getMain[songId]["image"]).replaceAll("150x150", "500x500");
  debugPrint((getMain[songId]["more_info"]["artistMap"]).toString());
  artist = (getMain[songId]["more_info"]["artistMap"]["primary_artists"][0]["name"]).toString().replaceAll("&quot;", "\"").replaceAll("&#039;", "'").replaceAll("&amp;", "&");
  album = (getMain[songId]["more_info"]["album"]).toString().replaceAll("&quot;", "\"").replaceAll("&#039;", "'").replaceAll("&amp;", "&");

  String lyricsApiUrl = "https://sumanjay.vercel.app/lyrics/" + artist + "/" + title;
  var lyricsApiRes = await http.get(lyricsApiUrl, headers: {"Accept": "application/json"});

  var lyricsResponse = json.decode(lyricsApiRes.body);
  if (lyricsResponse['status'] && lyricsResponse['lyrics'] != null) {
    lyrics = lyricsResponse['lyrics'];
  } else {
    lyrics = 'null';
  }

  has_320 = getMain[songId]["more_info"]["320kbps"];
  kUrl = await DesPlugin.decrypt(key, getMain[songId]["more_info"]["encrypted_media_url"]);
  //kUrl = kUrl.replaceAll("aac.saavncdn.com", "h.saavncdn.com").replaceAll("c.saavncdn.com", "h.saavncdn.com");
  rawkUrl = kUrl;

  final client = http.Client();
  final request = http.Request('HEAD', Uri.parse(kUrl))..followRedirects = false;
  final response = await client.send(request);
  kUrl = (response.headers['location']);
  debugPrint(kUrl);
}
