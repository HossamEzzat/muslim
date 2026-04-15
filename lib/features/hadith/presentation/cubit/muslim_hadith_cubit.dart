import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:muslim/features/hadith/data/models/muslim_hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/muslim_hadith_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class MuslimHadithState {}

class MuslimHadithInitial extends MuslimHadithState {}

class MuslimHadithLoading extends MuslimHadithState {}

class MuslimHadithLoaded extends MuslimHadithState {
  final List<MuslimHadithModel> hadiths;
  final List<MuslimHadithModel> filteredHadiths;
  final int currentIndex;

  MuslimHadithLoaded({
    required this.hadiths,
    required this.filteredHadiths,
    this.currentIndex = 0,
  });
}

class MuslimHadithError extends MuslimHadithState {
  final String message;
  MuslimHadithError(this.message);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class MuslimHadithCubit extends Cubit<MuslimHadithState> {
  final MuslimHadithRepository _repository;
  List<MuslimHadithModel> _allHadiths = [];

  MuslimHadithCubit(this._repository) : super(MuslimHadithInitial());

  Future<void> loadHadiths() async {
    emit(MuslimHadithLoading());
    try {
      final response = await _repository.fetchHadiths();
      _allHadiths = response.hadiths;

      emit(MuslimHadithLoaded(
        hadiths: _allHadiths,
        filteredHadiths: _allHadiths,
      ));
    } on SocketException {
      emit(MuslimHadithError('No internet connection'));
    } catch (e) {
      emit(MuslimHadithError(e.toString()));
    }
  }

  void search(String query) {
    if (state is! MuslimHadithLoaded) return;
    final filtered = query.isEmpty
        ? _allHadiths
        : _allHadiths
            .where(
              (h) =>
                  h.arab.contains(query) ||
                  h.id.contains(query) ||
                  h.number.toString().contains(query),
            )
            .toList();
    emit(MuslimHadithLoaded(
      hadiths: _allHadiths,
      filteredHadiths: filtered,
    ));
  }

  void updateIndex(int index) {
    if (state is MuslimHadithLoaded) {
      final loaded = state as MuslimHadithLoaded;
      emit(MuslimHadithLoaded(
        hadiths: loaded.hadiths,
        filteredHadiths: loaded.filteredHadiths,
        currentIndex: index,
      ));
    }
  }
}
