// ignore_for_file: non_constant_identifier_names

import 'package:test/test.dart';
import 'package:lyric_xx/lyric_xx.dart';

void main() {
  test_info_ignoreCase();
  test_encode();
  test_offsetTime();
  test_LyricSrcEntity_c();
  test_parse();
}

void test_info_ignoreCase() {
  test("歌词信息[LyricSrcEntity_c.info]忽略大小写", () {
    final lyric = LyricSrcEntity_c();
    lyric.info["HELLO"] = "WORLD";
    lyric.info["wow"] = "value";
    expect(lyric.info[""], null);
    expect(lyric.info["abc"], null);
    expect(lyric.info["HELLO"], "WORLD");
    expect(lyric.info["hello"], "WORLD");
    expect(lyric.info["WOW"], "value");
    expect(lyric.info["wow"], "value");
  });
}

void test_encode() {
  test("歌词信息 encode", () {
    final lyric = LyricSrcEntity_c();
    lyric.info["offset"] = 0;
    lyric.info["wo\nw"] = "niu :bi";
    lyric.info["tt:x"] = "niu \rbi";
    lyric.info["   tt:[j"] = "niu] \r\nbi  ";
    expect(
        Lyricxx_c.encodeLrcString(
          [
            LyricSrcItemEntity_c(
              time: 2,
              content: "hello coolight",
            ),
            LyricSrcItemEntity_c(
              time: 3,
              content: "wow coolight",
            ),
          ],
          info: lyric.info,
        ),
        """[wow:niu bi]
[ttj:niu bi]
[ttx:niu bi]
[offset:0]
[00:02.00]hello coolight
[00:03.00]wow coolight
""");
  });
}

void test_offsetTime() {
  test("歌词 line offset Time", () {
    final list = [
      LyricSrcItemEntity_c(
        time: 2,
        content: "hello coolight",
      ),
      LyricSrcItemEntity_c(
        time: -1,
        content: "hello coolight",
      ),
      LyricSrcItemEntity_c(
        time: 3,
        content: "wow coolight",
      ),
    ];

    List<LyricSrcItemEntity_c> copy() {
      return List.generate(list.length, (i) {
        return list[i].copyWith();
      });
    }

    void checkTime(List<LyricSrcItemEntity_c> inlist, List<double> times) {
      expect(inlist.length, times.length);
      for (int i = 0; i < inlist.length; ++i) {
        expect((inlist[i].time - times[i]).abs() < 0.0001, true);
      }
    }

    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, 2);
      checkTime(lrcs, [4, -1, 5]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -1);
      checkTime(lrcs, [1, -1, 2]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -2);
      checkTime(lrcs, [0, -1, 1]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -3);
      checkTime(lrcs, [0, -1, 0]);
    }
  });

  test("歌词 word offset Time", () {
    final list = [
      LyricSrcItemEntity_c(
        time: 2,
        timelist: [
          LyricSrcTime_c(
            time: 2,
            index: 0,
          ),
          LyricSrcTime_c(
            time: 2.5,
            index: 6,
          ),
          LyricSrcTime_c(
            time: 2.7,
            index: 14,
          ),
        ],
        content: "hello coolight",
      ),
      LyricSrcItemEntity_c(
        time: -1,
        content: "hello coolight",
      ),
      LyricSrcItemEntity_c(
        time: 3,
        timelist: [
          LyricSrcTime_c(
            time: 3,
            index: 0,
          ),
          LyricSrcTime_c(
            time: 3.2,
            index: 4,
          ),
          LyricSrcTime_c(
            time: 3.7,
            index: 12,
          ),
        ],
        content: "wow coolight",
      ),
    ];

    List<LyricSrcItemEntity_c> copy() {
      return List.generate(list.length, (i) {
        return list[i].copyWith();
      });
    }

    void checkTime(
        List<LyricSrcItemEntity_c> inlist, List<List<double>> times) {
      expect(inlist.length, times.length);
      print("================");
      for (int i = 0; i < inlist.length; ++i) {
        final timelist = inlist[i].timelist;
        print(times[i]);
        expect(timelist.length, times[i].length);
        for (int j = 0; j < timelist.length; ++j) {
          print(timelist[j].time);
          expect((timelist[j].time - times[i][j]).abs() < 0.0001, true);
        }
      }
    }

    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, 2);
      checkTime(lrcs, [
        [4, 4.5, 4.7],
        [],
        [5, 5.2, 5.7]
      ]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -1);
      checkTime(lrcs, [
        [1, 1.5, 1.7],
        [],
        [2, 2.2, 2.7]
      ]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -2);
      checkTime(lrcs, [
        [0, 0.5, 0.7],
        [],
        [1, 1.2, 1.7]
      ]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -2.5);
      checkTime(lrcs, [
        [0, 0, 0.2],
        [],
        [0.5, 0.7, 1.2]
      ]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -3);
      checkTime(lrcs, [
        [0, 0, 0],
        [],
        [0, 0.2, 0.7]
      ]);
    }
    {
      final lrcs = copy();
      Lyricxx_c.offsetTime(lrcs, -3.5);
      checkTime(lrcs, [
        [0, 0, 0],
        [],
        [0, 0, 0.2]
      ]);
    }
  });
}

void test_LyricSrcEntity_c() {
  test("LyricSrcEntity_c", () {
    final lyric = LyricSrcEntity_c();
    expect(lyric.getLrcItemByIndex(0), isNull);
    for (int i = 10; i-- > 0;) {
      lyric.lrc.add(LyricSrcItemEntity_c(time: i.toDouble()));
    }
    expect(lyric.getLrcItemByIndex(0), isNotNull);
    expect(lyric.getLrcItemByIndex(1), isNotNull);
    expect(lyric.getLrcItemByIndex(9), isNotNull);
    expect(lyric.getLrcItemByIndex(-1), isNull);
    expect(lyric.getLrcItemByIndex(10), isNull);
  });
}

void test_parse() {
  test("解码空歌词", () {
    expect(Lyricxx_c.decodeLrcString(""), isEmpty);
    expect(Lyricxx_c.decodeLrcString("      "), isEmpty);
    expect(Lyricxx_c.decodeLrcString("\n\n\n"), isEmpty);
    expect(Lyricxx_c.decodeLrcString("\r\n\r"), isEmpty);
    expect(Lyricxx_c.decodeLrcString("   \r\n\t"), isEmpty);
    expect(Lyricxx_c.decodeLrcString(" \n \n \n "), isEmpty);
    expect(Lyricxx_c.decodeLrcString("\r \n \r \t \n"), isEmpty);
  });

  test("解码单行LRC", () {
    // 信息标签
    var lyric = Lyricxx_c.decodeLrcString("[ti:天后]");
    expect(lyric.info_ti, "天后");
    lyric = Lyricxx_c.decodeLrcString("[TI:天后-2]  ++--");
    expect(lyric.info_ti, "天后-2");
    // 单行多个信息标签
    lyric = Lyricxx_c.decodeLrcString("  [TI:天后]abc[al:哈哈]aab[offset:+77]--");
    expect(lyric.info_ti, "天后");
    expect(lyric.info_al, "哈哈");
    expect(lyric.info_offset, 77);
    // 自定义信息标签
    lyric = Lyricxx_c.decodeLrcString("[WOW:天后-3]");
    expect(lyric.getInfoItemWithString("wow"), "天后-3");
    // offset
    lyric = Lyricxx_c.decodeLrcString("[Offset:123]");
    expect(lyric.info_offset, 123);
    lyric = Lyricxx_c.decodeLrcString("[Offset:+123]");
    expect(lyric.info_offset, 123);
    lyric = Lyricxx_c.decodeLrcString("[Offset:-123]");
    expect(lyric.info_offset, -123);
    lyric = Lyricxx_c.decodeLrcString("[Offset:-123.56]");
    expect(lyric.info_offset, -123.56);
    // 歌词
    lyric = Lyricxx_c.decodeLrcString("[00:27.43]终于找到借口");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 43.0 / 100.0);
    expect(lyric.getLrcItemByIndex(0)?.content, "终于找到借口");

    /// 空格移除
    lyric = Lyricxx_c.decodeLrcString("  [WOW: 天后 -  3 ]  ");
    expect(lyric.getInfoItemWithString("wow"), "天后 -  3");
    lyric = Lyricxx_c.decodeLrcString("  [00:27]  co  ol  ");
    expect(lyric.getLrcItemByIndex(0)?.content, "co  ol");
    lyric = Lyricxx_c.decodeLrcString("   [00:27]    ");
    expect(lyric.getLrcItemByIndex(0), null);
  });

  test("转义html字符", () {
    var lyric = Lyricxx_c.decodeLrcString(
      "[ti:&#60;洛天依&#62;]",
      parseHtmlEscape: true,
    );
    expect(lyric.info_ti, "<洛天依>");
    lyric = Lyricxx_c.decodeLrcString(
      "[00:27.000]&#60;洛天依&#62;&quot;",
      parseHtmlEscape: true,
    );
    expect(
      lyric.getLrcItemByIndex(0)?.content,
      "<洛天依>\"",
    );
  });
  test("解码LRC时间", () {
    // ms:1000
    var lyric = Lyricxx_c.decodeLrcString("[00:27.000]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = Lyricxx_c.decodeLrcString("[00:27.007]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 1000.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27.077]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 1000.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27.777]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 777.0 / 1000.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27:777]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 777.0 / 1000.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27.1000]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    // ms:100
    lyric = Lyricxx_c.decodeLrcString("[00:27.00]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = Lyricxx_c.decodeLrcString("[00:27.07]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 100.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27.77]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 100.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27:77]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 100.0);
    // ms:10
    lyric = Lyricxx_c.decodeLrcString("[00:27.0]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = Lyricxx_c.decodeLrcString("[00:27.7]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 10.0);
    lyric = Lyricxx_c.decodeLrcString("[00:27:7]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 10.0);
    // m:s
    lyric = Lyricxx_c.decodeLrcString("[00:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = Lyricxx_c.decodeLrcString("[01:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 60 + 27);
    lyric = Lyricxx_c.decodeLrcString("[0:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = Lyricxx_c.decodeLrcString("[000:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);

    /// 单行内连续多个时间
    lyric = Lyricxx_c.decodeLrcString(
      " abc  [0:27][00:37][000:47.11][00:57:33]cool",
    );
    expect(lyric.lrc.length, 4);
    expect(lyric.getLrcItemByIndex(0)?.content, "cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    expect(lyric.getLrcItemByIndex(1)?.time, 37);
    expect(lyric.getLrcItemByIndex(2)?.time, 47 + 11.0 / 100);
    expect(lyric.getLrcItemByIndex(3)?.time, 57 + 33.0 / 100);
    // 多个时间且间隔开
    // * 忽略前面没时间的abc
    // * 拆分为[00:27][00:47:33]cool和[000:37]light处理
    lyric = Lyricxx_c.decodeLrcString(
      " abc  [00:27][00:47:33]cool [000:37]light",
    );
    expect(lyric.lrc.length, 3);
    expect(lyric.getLrcItemByIndex(0)?.content, "cool");
    expect(lyric.getLrcItemByIndex(1)?.content, "light"); // 按时间排序
    expect(lyric.getLrcItemByIndex(2)?.content, "cool");

    lyric = Lyricxx_c.decodeLrcString(
      " abc  [0:27][00:37][000:47.11]abc [000:50.11] [00:57:33]cool",
    );
    expect(lyric.lrc.length, 4);

    /// 后置时间戳
    lyric = Lyricxx_c.decodeLrcString("cool[000:47.11][00:57:33]");
    expect(lyric.getLrcItemByIndex(0)?.time, 47 + 11.0 / 100);
    expect(lyric.getLrcItemByIndex(0)?.content, "cool");
    expect(lyric.getLrcItemByIndex(1)?.time, 57 + 33.0 / 100);
    expect(lyric.getLrcItemByIndex(1)?.content, "cool");

    /// 越界时间
    lyric = Lyricxx_c.decodeLrcString("[00:77:-1]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 0);
    lyric = Lyricxx_c.decodeLrcString("[01:-1:00]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 0);
  });

  test("解析逐字歌词", () {
    var lyric = Lyricxx_c.decodeLrcString("[00:27.00]cool[00:28.00]light");
    {
      expect(lyric.lrc.length, 1);
      expect(lyric.getLrcItemByIndex(0)?.time, 27);
      expect(lyric.getLrcItemByIndex(0)?.content, "coollight");
      expect(lyric.getLrcItemByIndex(0)?.isVerbatimTime, true);
      final timelist = lyric.getLrcItemByIndex(0)?.timelist;
      expect(timelist!.length, 2);
      expect(timelist[0].index, 0);
      expect(timelist[0].time, 27);
      expect(timelist[1].index, 4);
      expect(timelist[1].time, 28);
    }
    {
      // 多行逐字歌词，混合逐行歌词
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]cool[00:28.00]light[00:29.00]wow
[00:29.50]愿得一人心
白首不分离
[00:30.00]music[00:32.00]video[00:34.00]audio
""");
      expect(lyric.lrc.length, 4);
      expect(lyric.getLrcItemByIndex(0)?.time, 27);
      expect(lyric.getLrcItemByIndex(0)?.content, "coollightwow");
      expect(lyric.getLrcItemByIndex(0)?.timelist.length, 3);
      expect(lyric.getLrcItemByIndex(1)?.time, 29 + 50.0 / 100);
      expect(lyric.getLrcItemByIndex(1)?.content, "愿得一人心");
      expect(lyric.getLrcItemByIndex(1)?.isLineTime, true);
      expect(lyric.getLrcItemByIndex(2)?.time, -1);
      expect(lyric.getLrcItemByIndex(2)?.content, "白首不分离");
      expect(lyric.getLrcItemByIndex(2)?.isLineTime, true);
      expect(lyric.getLrcItemByIndex(3)?.time, 30);
      expect(lyric.getLrcItemByIndex(3)?.content, "musicvideoaudio");
      expect(lyric.getLrcItemByIndex(3)?.timelist.length, 3);
    }
    {
      // 逐字歌词，包含无时间翻译
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]cool[00:28.00]light[00:29.00]wow
翻译翻译，什么叫歌词
[00:30.00]music[00:32.00]video[00:34.00]audio
""");
      expect(lyric.lrc.length, 3);
      expect(lyric.getLrcItemByIndex(0)?.time, 27);
      expect(lyric.getLrcItemByIndex(0)?.content, "coollightwow");
      expect(lyric.getLrcItemByIndex(0)?.timelist, [
        LyricSrcTime_c(time: 27, index: 0),
        LyricSrcTime_c(time: 28, index: 4),
        LyricSrcTime_c(time: 29, index: 9)
      ]);
      expect(lyric.getLrcItemByIndex(1)?.time, -1);
      expect(lyric.getLrcItemByIndex(1)?.content, "翻译翻译，什么叫歌词");
      expect(lyric.getLrcItemByIndex(1)?.timelist.isEmpty, true);
      expect(lyric.getLrcItemByIndex(2)?.time, 30);
      expect(lyric.getLrcItemByIndex(2)?.content, "musicvideoaudio");
      expect(lyric.getLrcItemByIndex(2)?.timelist, [
        LyricSrcTime_c(time: 30, index: 0),
        LyricSrcTime_c(time: 32, index: 5),
        LyricSrcTime_c(time: 34, index: 10)
      ]);
    }
    {
      // 由于总行数小于3，且单词长度大于5，逐行歌词，包含无时间翻译
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]testfaild1[00:28.00]testfaild2[00:29.00]testfaild3
翻译翻译，什么叫歌词
""");
      expect(lyric.lrc.length, 4);
    }
    {
      // 由于总行数大于3，且单词长度大于5，逐字歌词，包含无时间翻译
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]testfaild1[00:28.00]testfaild2[00:29.00]testfaild3
翻译翻译，什么叫歌词
愿得一人心，白首不分离
听，海哭的声音
""");
      expect(lyric.lrc.length, 4);
      expect(lyric.getLrcItemByIndex(0)?.timelist.length, 3);
      expect(lyric.getLrcItemByIndex(1)?.timelist.length, 0);
      expect(lyric.getLrcItemByIndex(2)?.timelist.length, 0);
      expect(lyric.getLrcItemByIndex(3)?.timelist.length, 0);
    }
    {
      // 逐字歌词，包含结尾时间戳, 保留一个空格
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]cool[00:27.50] [00:28.00]light[00:29.00]  wow[00:30.00]
翻译翻译，什么叫歌词
[00:31.00]mus ic[00:32.00]video [00:33.00]   [00:34.00]audio[00:35.00]
""");
      expect(lyric.lrc.length, 3);
      expect(lyric.getLrcItemByIndex(0)?.time, 27);
      expect(lyric.getLrcItemByIndex(0)?.content, "cool light wow");
      expect(lyric.getLrcItemByIndex(0)?.timelist, [
        LyricSrcTime_c(time: 27, index: 0),
        LyricSrcTime_c(time: 27.5, index: 4),
        LyricSrcTime_c(time: 28, index: 5),
        LyricSrcTime_c(time: 29, index: 10),
        LyricSrcTime_c(time: 30, index: 14),
      ]);
      expect(lyric.getLrcItemByIndex(1)?.time, -1);
      expect(lyric.getLrcItemByIndex(1)?.content, "翻译翻译，什么叫歌词");
      expect(lyric.getLrcItemByIndex(1)?.timelist.isEmpty, true);
      expect(lyric.getLrcItemByIndex(2)?.time, 31);
      expect(lyric.getLrcItemByIndex(2)?.content, "mus icvideo  audio");
      expect(lyric.getLrcItemByIndex(2)?.timelist, [
        LyricSrcTime_c(time: 31, index: 0),
        LyricSrcTime_c(time: 32, index: 6),
        LyricSrcTime_c(time: 33, index: 12),
        LyricSrcTime_c(time: 34, index: 13),
        LyricSrcTime_c(time: 35, index: 18),
      ]);
    }
    {
      // 逐字歌词，混合两种时间戳表示
      lyric = Lyricxx_c.decodeLrcString(
          """[00:27.00]cool<00:27.50> <00:28.00>light<00:29.00>  wow<00:30.00>
翻译翻译，什么叫歌词
[00:31.00]mus ic[00:32.00]video [00:33.00]   [00:34.00]audio[00:35.00]
[00:41.00]mus< ic<00:42.00>vid>eo [00:43.00] <>  <00:44.00>au[]dio[00:45.00]
""");
      expect(lyric.lrc.length, 4);
      expect(lyric.getLrcItemByIndex(0)?.time, 27);
      expect(lyric.getLrcItemByIndex(0)?.content, "cool light wow");
      expect(lyric.getLrcItemByIndex(0)?.timelist, [
        LyricSrcTime_c(time: 27, index: 0),
        LyricSrcTime_c(time: 27.5, index: 4),
        LyricSrcTime_c(time: 28, index: 5),
        LyricSrcTime_c(time: 29, index: 10),
        LyricSrcTime_c(time: 30, index: 14),
      ]);
      expect(lyric.getLrcItemByIndex(1)?.time, -1);
      expect(lyric.getLrcItemByIndex(1)?.content, "翻译翻译，什么叫歌词");
      expect(lyric.getLrcItemByIndex(1)?.timelist.isEmpty, true);
      expect(lyric.getLrcItemByIndex(2)?.time, 31);
      expect(lyric.getLrcItemByIndex(2)?.content, "mus icvideo  audio");
      expect(lyric.getLrcItemByIndex(2)?.timelist, [
        LyricSrcTime_c(time: 31, index: 0),
        LyricSrcTime_c(time: 32, index: 6),
        LyricSrcTime_c(time: 33, index: 12),
        LyricSrcTime_c(time: 34, index: 13),
        LyricSrcTime_c(time: 35, index: 18),
      ]);
      expect(lyric.getLrcItemByIndex(3)?.time, 41);
      expect(lyric.getLrcItemByIndex(3)?.content, "mus< icvid>eo  <> au[]dio");
      expect(lyric.getLrcItemByIndex(3)?.timelist, [
        LyricSrcTime_c(time: 41, index: 0),
        LyricSrcTime_c(time: 42, index: 7),
        LyricSrcTime_c(time: 43, index: 14),
        LyricSrcTime_c(time: 44, index: 18),
        LyricSrcTime_c(time: 45, index: 25),
      ]);
    }
  });

  test("翻译歌词判断", () {
    LyricSrcEntity_c lyric;
    // 同时间
    lyric = Lyricxx_c.decodeLrcString("[000:47.11]LuoTianYi[00:47.11]洛天依");
    expect(lyric.isTranslate_original(0), true);
    expect(lyric.isTranslate(1), true);
    // 空时间
    lyric = Lyricxx_c.decodeLrcString("""
aaa
bbb
ccc
[000:47.11]LuoTianYi
洛天依
""");
    expect(lyric.isTranslate_original(0), false);
    expect(lyric.isTranslate(1), false);
    expect(lyric.isTranslate(2), false);
    expect(lyric.isTranslate_original(3), true);
    expect(lyric.isTranslate(4), true);
    // 空行
    lyric = Lyricxx_c.decodeLrcString("""
aaa
bbb
[000:47.11]LuoTianYi

洛天依
""");
    expect(lyric.isTranslate_original(0), false);
    expect(lyric.isTranslate(1), false);
    expect(lyric.isTranslate_original(2), true);
    expect(lyric.isTranslate(3), true);
  });
}
