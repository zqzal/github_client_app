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
    // refresh标记是否是"下拉刷新"
    bool refresh = options.extra["refresh"] == true;
    //如果是下拉刷新，先删除相关缓存
    if (refresh) {
      if (options.extra["list"] == true) {
        //若是列表，则只要url中包含当前path的缓存全部删除（简单实现，并不精准）
        cache.removeWhere((key, v) => key.contains(options.path));
      } else {
        // 如果不是列表，则只删除uri相同的缓存
        delete(options.uri.toString());
      }
      return options;
    }
    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == 'get') {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var ob = cache[key];
      if (ob != null) {
        //若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache.maxAge) {
          return cache[key].response;
        } else {
          //若已过期则删除缓存，继续向服务器请求
          cache.remove(key);
        }
      }
    }
  }

  @override
  Future onError(DioError err) async{
    // TODO: implement onError
    //错误状态下不缓存
  }

  @override
  Future onResponse(Response response) {
    // TODO: implement onResponse
    //如果启用缓存，将返回结果保存到缓存
    if(Global.profile.cache.enable){
      _saveCache(response);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }

  _saveCache(Response object) {
    RequestOptions options = object.request;
    if(options.extra["noCache"] != true && options.method.toLowerCase() == "get"){
      //如果缓存数量超过最大数量限制，则先移除最早的一条记录
      if(cache.length == Global.profile.cache.maxCount){
        cache.remove(cache[cache.keys.first]);
      }
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(object);
    }
  }
///refresh  bool 如果为true，则本次请求不使用缓存，但新的请求结果依然会被缓存
///noCache  bool 本次请亲禁用缓存，请求结果也不会被缓存




}