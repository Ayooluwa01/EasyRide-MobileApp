enum ToastType { success, error, info }

class ToastData {
  final String message;
  final ToastType type;

  const ToastData({required this.message, required this.type});
}
