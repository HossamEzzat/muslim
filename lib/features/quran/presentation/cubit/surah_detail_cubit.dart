import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim/features/quran/data/models/ayah_model.dart';
import 'package:muslim/features/quran/data/repositories/quran_repository.dart';
import 'dart:io';

abstract class SurahDetailState {}

class SurahDetailInitial extends SurahDetailState {}

class SurahDetailLoading extends SurahDetailState {}

class SurahDetailLoaded extends SurahDetailState {
  final List<AyahModel> ayahs;
  SurahDetailLoaded(this.ayahs);
}

class SurahDetailError extends SurahDetailState {
  final String message;
  SurahDetailError(this.message);
}

class SurahDetailCubit extends Cubit<SurahDetailState> {
  final QuranRepository _repository;

  SurahDetailCubit(this._repository) : super(SurahDetailInitial());

  Future<void> loadSurahDetails(int surahId) async {
    emit(SurahDetailLoading());
    try {
      final result = await InternetAddress.lookup('api.alquran.cloud');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(SurahDetailError('No internet connection'));
        return;
      }

      final ayahs = await _repository.getSurahDetails(surahId);
      emit(SurahDetailLoaded(ayahs));
    } on SocketException {
      emit(SurahDetailError('No internet connection'));
    } catch (e) {
      emit(SurahDetailError(e.toString()));
    }
  }
}
