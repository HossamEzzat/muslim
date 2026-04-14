import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:muslim/features/hadith/data/models/hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/hadith_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class HadithDetailState {}

class HadithDetailInitial extends HadithDetailState {}

class HadithDetailLoading extends HadithDetailState {}

class HadithDetailLoaded extends HadithDetailState {
  final List<HadithModel> hadiths;
  final int currentIndex;
  HadithDetailLoaded({
    required this.hadiths,
    this.currentIndex = 0,
  });
}

class HadithDetailError extends HadithDetailState {
  final String message;
  HadithDetailError(this.message);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class HadithDetailCubit extends Cubit<HadithDetailState> {
  final HadithRepository _repository;

  HadithDetailCubit(this._repository) : super(HadithDetailInitial());

  Future<void> loadHadiths(int sectionId) async {
    emit(HadithDetailLoading());
    try {
      final hadiths = await _repository.getHadithsBySection(sectionId);
      emit(HadithDetailLoaded(hadiths: hadiths));
    } on SocketException {
      emit(HadithDetailError('No internet connection'));
    } catch (e) {
      emit(HadithDetailError(e.toString()));
    }
  }

  void updateIndex(int index) {
    if (state is HadithDetailLoaded) {
      final loaded = state as HadithDetailLoaded;
      emit(HadithDetailLoaded(
        hadiths: loaded.hadiths,
        currentIndex: index,
      ));
    }
  }
}
