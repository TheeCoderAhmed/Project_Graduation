/// Validation for a Turkish national identity number (T.C. Kimlik No).
///
/// Rules:
///  - exactly 11 digits, first digit is not 0
///  - 10th digit = ((d1+d3+d5+d7+d9) * 7 - (d2+d4+d6+d8)) mod 10
///  - 11th digit = (d1..d10 sum) mod 10
class TcKimlik {
  /// Returns true if [value] is a structurally valid T.C. Kimlik No.
  static bool isValid(String value) {
    final v = value.trim();
    if (v.length != 11) return false;
    if (!RegExp(r'^[0-9]{11}$').hasMatch(v)) return false;
    final d = v.split('').map(int.parse).toList();
    if (d[0] == 0) return false;

    final oddSum = d[0] + d[2] + d[4] + d[6] + d[8];
    final evenSum = d[1] + d[3] + d[5] + d[7];
    final tenth = ((oddSum * 7) - evenSum) % 10;
    if (tenth != d[9]) return false;

    final first10 = d.sublist(0, 10).reduce((a, b) => a + b);
    if (first10 % 10 != d[10]) return false;

    return true;
  }
}
