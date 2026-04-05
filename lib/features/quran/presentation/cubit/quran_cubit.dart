import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';

// States
abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<SurahModel> suwar;
  final List<SurahModel> recentSuwar;
  final List<SurahModel> filteredSuwar;
  QuranLoaded({
    required this.suwar,
    required this.recentSuwar,
    required this.filteredSuwar,
  });
}

class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

// Cubit
class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _repository;
  final List<SurahModel> _allSuwar = [];

  QuranCubit(this._repository) : super(QuranInitial());

  Future<void> loadSuwar() async {
    emit(QuranLoading());
    try {
      // Quick connectivity check
      final result = await InternetAddress.lookup('mp3quran.net');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(QuranError('No internet connection'));
        return;
      }
      final suwar = await _repository.getSuwar();
      final recent = suwar.length >= 21 ? [suwar[20], suwar[0]] : [suwar[0]];
      emit(
        QuranLoaded(suwar: suwar, recentSuwar: recent, filteredSuwar: suwar),
      );
    } on SocketException {
      emit(QuranError('No internet connection'));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  void search(String query) {
    if (state is! QuranLoaded) return;
    final loaded = state as QuranLoaded;
    final filtered = query.isEmpty
        ? _allSuwar
        : _allSuwar
              .where(
                (s) =>
                    s.name.toLowerCase().contains(query.toLowerCase()) ||
                    s.arabicName.contains(query),
              )
              .toList();
    emit(
      QuranLoaded(
        suwar: loaded.suwar,
        recentSuwar: loaded.recentSuwar,
        filteredSuwar: filtered,
      ),
    );
  }
}
