//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import Foundation

final class CategoriesViewModel {
    var onCategoriesChanged: (() -> Void)?
    var onSelectedCategoryChanged: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private var selectedCategoryTitle: String?

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
    }

    var numberOfRows: Int {
        categories.count
    }

    var isEmpty: Bool {
        categories.isEmpty
    }

    func loadCategories() {
        do {
            categories = try categoryStore.fetchCategories()
            onCategoriesChanged?()
        } catch {
            onError?("Не удалось загрузить категории")
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel {
        let category = categories[indexPath.row]
        return CategoryCellViewModel(
            title: category.title,
            isSelected: category.title == selectedCategoryTitle
        )
    }

    func selectCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategoryTitle = category.title
        onCategoriesChanged?()
        onSelectedCategoryChanged?(category.title)
    }

    func addCategory(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        do {
            if try categoryStore.fetchCategory(title: trimmedTitle) == nil {
                _ = try categoryStore.addCategory(title: trimmedTitle)
            }
            selectedCategoryTitle = trimmedTitle
            loadCategories()
            onSelectedCategoryChanged?(trimmedTitle)
        } catch {
            onError?("Не удалось сохранить категорию")
        }
    }
}
