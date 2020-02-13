import 'package:dio/dio.dart';
import 'dart:collection';
import 'package:github_client_app/model/index.dart';
import 'global.dart';
///缓存策略：将请求的url作为key，对请求的返回值在一个指定时间段类
///进行缓存，另外设置一个最大缓存数，当超过最大缓存数后移除最早的一条缓存。
///但是也要提供一种针对特定接口或请求决定是否启用缓存的机制，这种机制可以指定那些接口
///或那次请求不应用缓存，这种机制是很有必要的，比如登录接口就不应该缓存，又比如用户在
///下拉刷新时就不应该在应用缓存。在实现缓存之前我们先定义保存缓存信息的CachObject类：
class CacheObject{
  CacheObject(this.response) : timeStamp = DateTime.now().millisecondsSinceEpoch;
  Response response;
  int timeStamp; //缓存创建时间

  @override
  bool operator ==(other) {
    // TODO: implement ==
    return response.hashCode == other.hashCode;
  }

  //将请求uri作为缓存的key
  @override
  // TODO: implement hashCode
  int get hashCode => response.realUri.hashCode;

}

class NetCache extends Interceptor{

  //为确保迭代器顺序和对象插入时间一致顺序一致，我们使用LinkedHashMap
  var cache = LinkedHashMap<String,CacheObject>();

  @override
  Future onRequest(RequestOptions options) async {
    if (!Global.profile.cache.enable) return options;



    // TODO: implement onRequest
    return super.onRequest(options);
  }

}