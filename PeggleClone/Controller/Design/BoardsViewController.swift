//
//  BoardsViewController.swift
//  PeggleClone
//
//  Created by Kyle キラ on 22/1/22.
//

import UIKit
import CoreData

class BoardsViewController: UIViewController {

    @IBOutlet private var boardCollectionView: UICollectionView!

    struct Storyboard {
        static let collectionViewCell = "BoardCollectionViewCell"
        static let sectionHeaderView = "BoardsHeaderCollectionReusableView"
        static let designViewController = "designViewController"
    }

    private let userDefaults = UserDefaults.standard
    private let houseImage = UIImage(systemName: "house")
    private let boardCategories = ["Templates", "DIY"]
    private let numberOfSections = 2
    private let itemWidth = 200.0
    private let itemHeight = 250.0
    private let headerHeight = 50.0

    private let viewModel = BoardsViewModel()

    private func fetchBoardViewModels() {
        showSpinner()
        do {
            try viewModel.fetchBoardViewModels(for: self)
        } catch {
            // Handles error code and alerts the user
            let alertStatus = viewModel.getAlertText(from: (error as NSError).code)
            Alert.showBasic(
                title: alertStatus.title,
                message: alertStatus.message,
                vc: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        playBackgroundMusic()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupBinders()
        setupBoardCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchBoardViewModels()
    }

    @objc func goToHomePage() {
        dismiss(animated: true, completion: nil)
    }

    private func setupBoardCollectionView() {
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        boardCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }

    private func setupViews() {
        title = userDefaults.string(forKey: "loadPageTitle")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: houseImage,
            style: .done, target: self, action: #selector(goToHomePage))
    }

    private func setupBinders() {
        // Observes BoardViewModels
        viewModel.bindToBoardViewModels { [weak self] _ in
            DispatchQueue.main.async {
                self?.boardCollectionView.reloadData()
                self?.removeSpinner()
            }
        }

        // Observes selectedBoardViewModel
        viewModel.selectedBoardViewModel.bind { [weak self] selectedBoardViewModel in
            guard let selectedBoardViewModel = selectedBoardViewModel else {
                return
            }

            self?.presentDesignView(selectedBoardViewModel: selectedBoardViewModel)
        }
    }

    private func presentDesignView(selectedBoardViewModel: BoardViewModel) {

        guard let designViewController = self.storyboard?.instantiateViewController(
            withIdentifier: Storyboard.designViewController) as? DesignViewController else {
                return
            }

        designViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            designViewController.setDesignViewModel(boardViewModel: selectedBoardViewModel)

            self.present(designViewController, animated: true)
        }
    }
}

extension BoardsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
            CGSize(width: view.frame.size.width, height: headerHeight)
        }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {

            let sectionHeaderView = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: Storyboard.sectionHeaderView,
                    for: indexPath)

            guard let sectionHeaderView = (sectionHeaderView as? BoardsHeaderCollectionReusableView) else {
                return sectionHeaderView
            }

            let category = boardCategories[indexPath.section]
            sectionHeaderView.categoryTitle = category

            return sectionHeaderView
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getBoardViewModelsCount(section: section)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        numberOfSections
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView
                .dequeueReusableCell(
                    withReuseIdentifier: Storyboard.collectionViewCell, for: indexPath)

            guard let cell = (cell as? BoardCollectionViewCell) else {
                return cell
            }

            if let boardViewModel = viewModel.getBoardViewModel(for: indexPath) {
                cell.boardViewModel = boardViewModel
            }

            return cell
        }
}

extension BoardsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            CGSize(width: itemWidth, height: itemHeight)
        }
}

extension BoardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playClickSoundEffect()
        viewModel.getSelectedBoardViewModel(for: indexPath)
    }
}

extension BoardsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        boardCollectionView.reloadData()
    }
}

extension BoardsViewController {
    private func playBackgroundMusic() {
        let artist = SoundArtist.artist
        artist.stopAllMusicPlayers()

        if let player = artist.menuMusicPlayer {
            if !player.isPlaying {
                player.prepareToPlay()
                player.numberOfLoops = -1
                player.play()

            }
        }
    }

    private func playClickSoundEffect() {
        if let player = SoundArtist.artist.clickSoundPlayer {
            player.play()
        }
    }
}
