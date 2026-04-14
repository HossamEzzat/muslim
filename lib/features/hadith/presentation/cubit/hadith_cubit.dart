import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:muslim/features/hadith/data/models/hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/hadith_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class HadithState {}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithSectionsLoaded extends HadithState {
  final List<HadithSectionModel> sections;
  final List<HadithSectionModel> filteredSections;
  HadithSectionsLoaded({
    required this.sections,
    required this.filteredSections,
  });
}

class HadithError extends HadithState {
  final String message;
  HadithError(this.message);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository _repository;
  final List<HadithSectionModel> _allSections = [];

  HadithCubit(this._repository) : super(HadithInitial());

  Future<void> loadSections() async {
    emit(HadithLoading());
    try {
      final result = await InternetAddress.lookup('cdn.jsdelivr.net');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(HadithError('No internet connection'));
        return;
      }

      final sections = await _repository.getSections();
      _allSections.clear();
      _allSections.addAll(sections);

      emit(HadithSectionsLoaded(
        sections: _allSections,
        filteredSections: _allSections,
      ));
    } on SocketException {
      emit(HadithError('No internet connection'));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  void search(String query) {
    if (state is! HadithSectionsLoaded) return;
    final filtered = query.isEmpty
        ? _allSections
        : _allSections
              .where(
                (s) => s.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    emit(HadithSectionsLoaded(
      sections: _allSections,
      filteredSections: filtered,
    ));
  }
}
