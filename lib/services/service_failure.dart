/// A friendly error message from the org and attendance services.
/// Providers catch it and show its message in a SnackBar.
class OrgFailure implements Exception{
  final String message;
  const OrgFailure(this.message);
}
