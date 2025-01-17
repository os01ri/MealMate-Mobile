import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as go_router;

extension RoutingExtension on BuildContext {
  void myGo(String path, {Object? extra}) => go_router.GoRouter.of(this).go(path, extra: extra);

  void myGoNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      go_router.GoRouter.of(this).goNamed(
        name,
        extra: extra,
        params: params,
        queryParams: queryParams,
      );

  Future<T?> myPush<T extends Object?>(String path, {Object? extra}) => go_router.GoRouter.of(this).push(
        path,
        extra: extra,
      );

  void myPushReplacement(
    String path, {
    Object? extra,
  }) =>
      go_router.GoRouter.of(this).pushReplacement(
        path,
        extra: extra,
      );

  Future<T?> myPushNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      go_router.GoRouter.of(this).pushNamed(
        name,
        extra: extra,
        params: params,
        queryParams: queryParams,
      );

  void myPushReplacementNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      go_router.GoRouter.of(this).pushReplacementNamed(
        name,
        extra: extra,
        params: params,
        queryParams: queryParams,
      );

  myPop<T extends Object?>([T? result]) => go_router.GoRouter.of(this).pop(result);

  myCanPop() => go_router.GoRouter.of(this).canPop();

  aboutApp(
    Widget applicationIcon,
    String applicationLegalese,
    String applicationName,
    String applicationVersion,
  ) =>
      AboutDialog(
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
        applicationName: applicationName,
        applicationVersion: applicationVersion,
      );
}
