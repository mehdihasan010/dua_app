Future<T?> catchAndReturnFuture<T>(Future<T> Function() future) async {
  try {
    return await future();
  } catch (e) {
    return null;
  }
}
