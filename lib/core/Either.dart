import 'package:equatable/equatable.dart';

// Kelas abstrak yang merepresentasikan sebuah nilai yang bisa berupa Tipe Kiri (L) atau Tipe Kanan (R).
// Dalam arsitektur ini, kita gunakan sebagai konvensi:
// L (Left) -> Tipe untuk Kegagalan (Failure)
// R (Right) -> Tipe untuk Keberhasilan (Success)
abstract class Either<L, R> extends Equatable {
  const Either();

  // Method 'fold' adalah cara elegan untuk mengekstrak nilai dari dalam Either.
  // Ia memaksa kita untuk menangani kedua kasus (gagal atau sukses) sekaligus.
  // 'ifLeft' akan dieksekusi jika ini adalah Left, dan 'ifRight' jika ini adalah Right.
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight);

  @override
  List<Object?> get props => [];
}

// Implementasi konkret dari Either untuk kasus Kegagalan (Left).
// Ia membawa sebuah nilai bertipe L (Failure).
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) {
    return ifLeft(value);
  }

  @override
  List<Object?> get props => [value];
}

// Implementasi konkret dari Either untuk kasus Keberhasilan (Right).
// Ia membawa sebuah nilai bertipe R (Success data).
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) {
    return ifRight(value);
  }

   @override
  List<Object?> get props => [value];
}
