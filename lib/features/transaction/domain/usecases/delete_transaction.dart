import 'package:equatable/equatable.dart';

// Import kerangka arsitektur dari folder core
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';

// Import kontrak repository
import 'package:cashwise/features/transaction/domain/repositories/transaction_repository.dart';

// Usecase ini bertanggung jawab untuk menghapus sebuah transaksi.
// Ia mengimplementasikan Usecase dan mendefinisikan bahwa ia akan mengembalikan void (tidak ada apa-apa) jika berhasil,
// dan membutuhkan parameter 'Params' (yang berisi ID transaksi).
class DeleteTransaction implements UseCase<void, Params> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  // Saat usecase ini dipanggil, ia akan meneruskan panggilan ke method deleteTransaction di repository.
  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await repository.deleteTransaction(params.id);
  }
}

// Kelas ini dibuat khusus untuk membawa parameter yang dibutuhkan oleh DeleteTransaction,
// yaitu ID dari transaksi yang akan dihapus.
class Params extends Equatable {
  final int id;

  const Params({required this.id});

  @override
  List<Object> get props => [id];
}
