// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';

import 'package:my_lyric/my_lyric.dart';

void main() {
  test_info_ignoreCase();
  test_LyricSrcEntity_c();
  test_parse();
}

void test_info_ignoreCase() {
  test("测试歌词信息[LyricSrcEntity_c.info]忽略大小写", () {
    final lyric = LyricSrcEntity_c();
    lyric.info["HELLO"] = "WORLD";
    lyric.info["wow"] = "value";
    expect(lyric.info["HELLO"], "WORLD");
    expect(lyric.info["hello"], "WORLD");
    expect(lyric.info["WOW"], "value");
    expect(lyric.info["wow"], "value");
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
  test("测试解码空歌词", () {
    expect(MyLyric_c.decodeLrcString(""), isEmpty);
    expect(MyLyric_c.decodeLrcString("      "), isEmpty);
    expect(MyLyric_c.decodeLrcString("\n\n\n"), isEmpty);
    expect(MyLyric_c.decodeLrcString("\r\n\r"), isEmpty);
    expect(MyLyric_c.decodeLrcString("   \r\n\t"), isEmpty);
    expect(MyLyric_c.decodeLrcString(" \n \n \n "), isEmpty);
    expect(MyLyric_c.decodeLrcString("\r \n \r \t \n"), isEmpty);
  });

  test("测试解码单行LRC", () {
    var lyric = MyLyric_c.decodeLrcString("[ti:天后]");
    expect(lyric.info_ti, "天后");
    lyric = MyLyric_c.decodeLrcString("[Offset:123]");
    expect(lyric.info_offset, 123);
    lyric = MyLyric_c.decodeLrcString("[Offset:+123]");
    expect(lyric.info_offset, 123);
    lyric = MyLyric_c.decodeLrcString("[Offset:-123]");
    expect(lyric.info_offset, -123);
    lyric = MyLyric_c.decodeLrcString("[Offset:-123.56]");
    expect(lyric.info_offset, -123.56);
    lyric = MyLyric_c.decodeLrcString("[TI:天后-2]");
    expect(lyric.info_ti, "天后-2");
    lyric = MyLyric_c.decodeLrcString("[WOW:天后-3]");
    expect(lyric.getInfoItemWithString("wow"), "天后-3");
    lyric = MyLyric_c.decodeLrcString("[00:27.43]终于找到借口");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 43.0 / 100.0);
    expect(lyric.getLrcItemByIndex(0)?.content, "终于找到借口");
  });

  test("测试解码LRC时间", () {
    // ms:1000
    var lyric = MyLyric_c.decodeLrcString("[00:27.000]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = MyLyric_c.decodeLrcString("[00:27.007]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 1000.0);
    lyric = MyLyric_c.decodeLrcString("[00:27.077]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 1000.0);
    lyric = MyLyric_c.decodeLrcString("[00:27.777]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 777.0 / 1000.0);
    lyric = MyLyric_c.decodeLrcString("[00:27:777]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 777.0 / 1000.0);
    lyric = MyLyric_c.decodeLrcString("[00:27.1000]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    // ms:100
    lyric = MyLyric_c.decodeLrcString("[00:27.00]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = MyLyric_c.decodeLrcString("[00:27.07]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 100.0);
    lyric = MyLyric_c.decodeLrcString("[00:27.77]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 100.0);
    lyric = MyLyric_c.decodeLrcString("[00:27:77]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 77.0 / 100.0);
    // ms:10
    lyric = MyLyric_c.decodeLrcString("[00:27.0]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = MyLyric_c.decodeLrcString("[00:27.7]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 10.0);
    lyric = MyLyric_c.decodeLrcString("[00:27:7]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27 + 7.0 / 10.0);
    // m:s
    lyric = MyLyric_c.decodeLrcString("[00:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = MyLyric_c.decodeLrcString("[01:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 60 + 27);
    lyric = MyLyric_c.decodeLrcString("[0:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    lyric = MyLyric_c.decodeLrcString("[000:27]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);

    /// 单行内连续多个时间
    lyric = MyLyric_c.decodeLrcString("[0:27][00:37][000:47.11][00:57:33]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 27);
    expect(lyric.getLrcItemByIndex(1)?.time, 37);
    expect(lyric.getLrcItemByIndex(2)?.time, 47 + 11.0 / 100);
    expect(lyric.getLrcItemByIndex(3)?.time, 57 + 33.0 / 100);

    /// 空格移除
    lyric = MyLyric_c.decodeLrcString("[00:27]  co  ol  ");
    expect(lyric.getLrcItemByIndex(0)?.content, "co  ol");
    lyric = MyLyric_c.decodeLrcString("[00:27]    ");
    expect(lyric.getLrcItemByIndex(0), null);

    /// 后置时间戳
    lyric = MyLyric_c.decodeLrcString("cool[000:47.11][00:57:33]");
    expect(lyric.getLrcItemByIndex(0)?.time, 47 + 11.0 / 100);
    expect(lyric.getLrcItemByIndex(0)?.content, "cool");
    expect(lyric.getLrcItemByIndex(1)?.time, 57 + 33.0 / 100);
    expect(lyric.getLrcItemByIndex(1)?.content, "cool");

    /// 越界时间
    lyric = MyLyric_c.decodeLrcString("[00:77:77]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 77 + 77.0 / 100.0);
    lyric = MyLyric_c.decodeLrcString("[00:77:10000]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 77);
    lyric = MyLyric_c.decodeLrcString("[00:77:-1]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 0);
    lyric = MyLyric_c.decodeLrcString("[01:-1:00]cool");
    expect(lyric.getLrcItemByIndex(0)?.time, 0);
  });
}
