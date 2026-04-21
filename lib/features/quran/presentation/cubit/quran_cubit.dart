import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim/features/quran/data/models/surah_model.dart';
import 'package:muslim/features/quran/data/repositories/quran_repository.dart';

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
  static const String _recentSuwarKey = 'recent_suwar_ids';

  QuranCubit(this._repository) : super(QuranInitial());

  Future<void> loadSuwar() async {
    emit(QuranLoading());
    try {
      final suwar = await _repository.getSuwar();
      _allSuwar.clear();
      _allSuwar.addAll(suwar);

      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList(_recentSuwarKey) ?? [];

      List<SurahModel> recent = [];
      for (var idStr in recentIds) {
        final id = int.tryParse(idStr);
        if (id != null) {
          final found = _allSuwar.where((s) => s.id == id);
          if (found.isNotEmpty) {
            recent.add(found.first);
          }
        }
      }

      // Default fallback if no recent
      if (recent.isEmpty && _allSuwar.isNotEmpty) {
        recent = _allSuwar.length >= 21 ? [_allSuwar[20], _allSuwar[0]] : [_allSuwar[0]];
      }

      emit(
        QuranLoaded(suwar: _allSuwar, recentSuwar: recent, filteredSuwar: _allSuwar),
      );
    } on SocketException {
      emit(QuranError('No internet connection'));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  Future<void> addRecentSurah(int surahId) async {
    if (state is! QuranLoaded) return;
    final loaded = state as QuranLoaded;

    final prefs = await SharedPreferences.getInstance();
    List<String> recentIds = prefs.getStringList(_recentSuwarKey) ?? [];

    // Remove if already exists so it can be moved to the front
    recentIds.remove(surahId.toString());
    recentIds.insert(0, surahId.toString());

    // Keep only top 5 recent
    if (recentIds.length > 5) {
      recentIds = recentIds.sublist(0, 5);
    }

    await prefs.setStringList(_recentSuwarKey, recentIds);

    List<SurahModel> updatedRecent = [];
    for (var idStr in recentIds) {
      final id = int.tryParse(idStr);
      if (id != null) {
        final found = _allSuwar.where((s) => s.id == id);
        if (found.isNotEmpty) {
          updatedRecent.add(found.first);
        }
      }
    }

    emit(QuranLoaded(
      suwar: loaded.suwar,
      recentSuwar: updatedRecent,
      filteredSuwar: loaded.filteredSuwar,
    ));
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
