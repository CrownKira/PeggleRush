//
//  ViewController.swift
//  PeggleClone
//
//  Created by Kyle キラ on 21/1/22.
//

import UIKit

class DesignViewController: UIViewController {

    struct Storyboard {
        static let playViewController = "playViewController"
    }

    @IBOutlet private var rotationSlider: UISlider!
    @IBOutlet private var sizeSlider: UISlider!
    @IBOutlet private var triangleBlockImageView: UIImageView!
    @IBOutlet private var purplePegImageView: UIImageView!
    @IBOutlet private var greenPegImageView: UIImageView!
    @IBOutlet private var bluePegImageView: UIImageView!
    @IBOutlet private var orangePegImageView: UIImageView!
    @IBOutlet private var deletePegImageView: UIImageView!
    @IBOutlet private var boardScrollView: UIScrollView!
    @IBOutlet private var boardView: UIView!
    @IBOutlet private var boardNameTextField: UITextField!
    @IBOutlet private var levelHeightLabel: UILabel!
    @IBOutlet private var deleteButton: UIButton!
    @IBOutlet private var levelHeightStepper: UIStepper!
    @IBOutlet private var boardViewHeight: NSLayoutConstraint!

    private var viewModel = DesignViewModel(boardViewModel: nil)
    private var pegViewModelsOnBoard = [UIImageView: PegViewModel]()
    private var blockViewModelsOnBoard = [UIImageView: BlockViewModel]()
    private var blockImageViewsOnBoard = [UIImageView: UIImageView]()
    private var arrowImageView: UIImageView = {
        let arrowWidth = 30.0
        let arrowHeight = 30.0

        let imageView = UIImageView(frame: CGRect(
            origin: CGPoint(),
            size: CGSize(width: arrowWidth, height: arrowHeight)))
        imageView.image = #imageLiteral(resourceName: "peg-red-glow-triangle")
        imageView.alpha = 0
        return imageView
    }()

    var isBoardViewModelLoaded: Bool {
        viewModel.isBoardViewModelLoaded
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playBackgroundMusic()

        setupViews()
        setupBinders()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel.isBoardViewModelLoaded else {
            dismiss(animated: true, completion: nil)
            return
        }

        setupRecognizers()
        setupKeyboardToggleHandlers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.isBoardViewModelLoaded else {
            self.goToBoardsPage()
            return
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        levelHeightStepper.minimumValue = boardScrollView.bounds.height
        viewModel.setBoardViewModelBounds(boardScrollView.bounds)
    }

    func setDesignViewModel(boardViewModel: BoardViewModel) {
        viewModel = DesignViewModel(boardViewModel: boardViewModel)
    }
}

// MARK: - Setup Views

extension DesignViewController {

    private func setupArrow(above imageView: UIView) {
        let arrowOffset = 10.0
        let arrowCenter = CGPoint(
            x: imageView.center.x,
            y: imageView.center.y
            - imageView.frame.height - arrowOffset)
        arrowImageView.center = arrowCenter
        arrowImageView.alpha = 1
    }

    private func setupViews() {
        boardView.addSubview(arrowImageView)
        self.boardNameTextField.text = viewModel.boardNameText
    }

    private func goToBoardsPage() {
        dismiss(animated: true, completion: nil)
    }

    @objc func boardViewTapped(_ sender: UITapGestureRecognizer) {
        playBoardSoundEffect()

        let location = sender.location(in: boardScrollView)
        viewModel.addItem(to: location)
    }

    @objc func paletteButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedViewTag = sender.view?.tag else {
            return
        }

        viewModel.setSelectedButton(tag: tappedViewTag)
    }

    @IBAction private func resetButtonPressed(_ sender: UIButton) {
        viewModel.reset()
    }

    @IBAction private func saveButtonPressed(_ sender: UIButton) {

        guard let boardName = boardNameTextField.text, !boardName.isEmpty else {
            showEnterNamePrompt()
            return
        }

        // Updates board view model
        viewModel.setBoardViewModelName(boardName)
        if let imageData = BoardViewModel.backgroundImage.mergeWith(
            topImage: boardScrollView.snapshotVisibleArea).pngData() {
            viewModel.setBoardViewModelImage(imageData)
        }

        // Saves to database
        do {
            try viewModel.save()
            showSaveSuccessMessage()
        } catch {
            let alertStatus = viewModel.getSaveAlertText(from: (error as NSError).code)
            Alert.showBasic(
                title: alertStatus.title,
                message: alertStatus.message,
                vc: self)
        }
    }

    @IBAction private func loadButtonPressed(_ sender: UIButton) {
        goToBoardsPage()
    }

    @IBAction private func rotationSliderPanned(_ sender: UISlider) {
        do {
            try viewModel.rotateSelectedItem(to: Double(sender.value))
        } catch ValidationError.invalidAngle {
            showItemInvalidSizeMessage()
            return
        } catch {
            Alert.showGenericError(vc: self)
            return
        }
    }

    @IBAction private func sizeSliderPanned(_ sender: UISlider) {
        do {
            try viewModel.resizeSelectedItem(to: Double(sender.value))
        } catch ValidationError.invalidSize {
            showItemInvalidSizeMessage()
            return
        } catch {
            Alert.showGenericError(vc: self)
            return
        }
    }

    @IBAction private func deleteButtonPressed(_ sender: UIButton) {
        showDeletionConfirmMessage()
    }

    private func handleDelete(alertAction: UIAlertAction) {
        do {
            try viewModel.delete()
            goToBoardsPage()
        } catch {
            let alertStatus = viewModel.getDeleteAlertText(from: (error as NSError).code)

            Alert.showBasic(
                title: alertStatus.title,
                message: alertStatus.message,
                vc: self)
        }
    }

    @IBAction private func levelHeightStepperPressed(_ sender: UIStepper) {
        do {
            try viewModel.setBoardContentHeight(sender.value)
        } catch ValidationError.invalidContentHeight {
            showInvalidContentHeightMessage()
            return
        } catch {
            Alert.showGenericError(vc: self)
            return
        }
    }

    @IBAction private func startButtonPressed(_ sender: Any) {
        presentPlayView()
    }

    private func presentPlayView() {
        guard let boardViewModel = viewModel.boardViewModel.value else {
            return
        }

        guard let playViewController = storyboard?.instantiateViewController(
            withIdentifier: Storyboard.playViewController) as? PlayViewController else {
                return
            }
        playViewController.modalPresentationStyle = .fullScreen
        playViewController.setPlayViewModel(boardViewModel: boardViewModel)

        present(playViewController, animated: true)
    }

}

// MARK: - Setup Keyboard

extension DesignViewController {

    private func setupKeyboardToggleHandlers() {
        // Prevents keyboard from blocking the text field
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (
            notification
                .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            if keyboardSize.height > self.view.frame.origin.y * -1 {
                self.view.frame.origin.y = keyboardSize.height * -1
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}

// MARK: - Setup Recognizers

extension DesignViewController {

    private func setupRecognizers() {
        addUITapRecognizer(to: bluePegImageView, action: #selector(paletteButtonTapped(_:)))
        addUITapRecognizer(to: orangePegImageView, action: #selector(paletteButtonTapped(_:)))
        addUITapRecognizer(to: greenPegImageView, action: #selector(paletteButtonTapped(_:)))
        addUITapRecognizer(to: purplePegImageView, action: #selector(paletteButtonTapped(_:)))
        addUITapRecognizer(to: triangleBlockImageView, action: #selector(paletteButtonTapped(_:)))
        addUITapRecognizer(to: deletePegImageView, action: #selector(paletteButtonTapped(_:)))

        addUITapRecognizer(to: boardScrollView, action: #selector(boardViewTapped(_:)))
    }

    private func addUITapRecognizer(to viewToInteract: UIView, action: Selector?) {
        let UITapRecognizer = UITapGestureRecognizer(target: self, action: action)
        UITapRecognizer.numberOfTouchesRequired = 1
        UITapRecognizer.numberOfTouchesRequired = 1
        viewToInteract.isUserInteractionEnabled = true
        viewToInteract.addGestureRecognizer(UITapRecognizer)
    }

    private func addUILongPressedRecognizer(to viewToInteract: UIView, action: Selector?) {
        let UILongPressedRecognizer = UILongPressGestureRecognizer(target: self, action: action)
        UILongPressedRecognizer.minimumPressDuration = 1.0
        viewToInteract.isUserInteractionEnabled = true
        viewToInteract.addGestureRecognizer(UILongPressedRecognizer)
    }

    private func addUIPanRecognizer(to viewToInteract: UIView, action: Selector?) {
        let UIPanRecognizer = UIPanGestureRecognizer(target: self, action: action)
        viewToInteract.isUserInteractionEnabled = true
        viewToInteract.addGestureRecognizer(UIPanRecognizer)
    }
}

// MARK: - Setup Binders

extension DesignViewController {

    private func bindToSelectedBoardItemViewModel() {
        // Observes selected board item view model
        viewModel.bindToSelectedBoardItemViewModel { [weak self] selectedBoardItemViewModel in

            let shouldEnableSlider = selectedBoardItemViewModel != nil
            let shouldEnableArrow = selectedBoardItemViewModel != nil

            DispatchQueue.main.async {
                self?.rotationSlider.isEnabled = shouldEnableSlider
                self?.sizeSlider.isEnabled = shouldEnableSlider

                if let selectedBoardItemViewModel = selectedBoardItemViewModel {
                    self?.sizeSlider.maximumValue = Float(selectedBoardItemViewModel.maxWidth)
                }

                self?.arrowImageView.alpha = shouldEnableArrow ? 1 : 0
            }
        }
    }

    private func bindToBoardSaveStatus() {
        // Observes save status
        viewModel.bindToBoardSaveStatus { [weak self] isBoardNew in
            DispatchQueue.main.async {
                self?.deleteButton.isEnabled = !isBoardNew
            }
        }
    }

    private func bindToContentHeight() {
        // Observes content height
        viewModel.bindToContentHeight { [weak self] contentHeight in
            guard let contentHeight = contentHeight else {
                return
            }

            DispatchQueue.main.async {
                self?.levelHeightStepper.value = contentHeight
                self?.boardViewHeight.constant = contentHeight
                self?.levelHeightLabel.text = String(Int(contentHeight))
            }
        }
    }

    private func bindToBlockViewModels() {
        // Observes blockViewModels
        viewModel.bindToBlockViewModels { [weak self] blockViewModels in
            DispatchQueue.main.async {
                self?.render(blockViewModels: Set(blockViewModels.values))
            }
        }
    }

    private func bindToPegViewModels() {
        // Observes pegViewModels
        viewModel.bindToPegViewModels { [weak self] pegViewModels in
            DispatchQueue.main.async {
                self?.render(pegViewModels: Set(pegViewModels.values))
            }
        }
    }

    private func bindToSelectedButton() {
        // Observes selectedButton
        viewModel.selectedButton.bind { [weak self] selectedButton in
            // Updates selected button UI
            let paletteButtons = [
                self?.bluePegImageView,
                self?.orangePegImageView,
                self?.greenPegImageView,
                self?.purplePegImageView,
                self?.deletePegImageView,
                self?.triangleBlockImageView
            ]

            for button in paletteButtons {
                guard let button = button else {
                    return
                }

                if button.tag == selectedButton.rawValue {
                    button.alpha = 1
                } else {
                    button.alpha = 0.5
                }
            }
        }
    }

    private func bindToItemPanned() {
        // Observes itemPanned
        viewModel.bindToItemPanned { [weak self] itemPanned in
            guard let itemPanned = itemPanned else {
                return
            }

            self?.moveViewWithPan(viewToMove: itemPanned.pegView, sender: itemPanned.sender)
        }
    }

    private func bindToBlockCornerPanned() {
        // Observes block corners panned
        viewModel.bindToBlockCornerPanned { [weak self] blockCornerPanned in
            guard let blockCornerPanned = blockCornerPanned else {
                return
            }

            self?.reshapeBlockWithPan(blockCornerPanned)
        }
    }

    private func setupBinders() {
        bindToSelectedBoardItemViewModel()
        bindToBoardSaveStatus()
        bindToContentHeight()
        bindToBlockViewModels()
        bindToPegViewModels()
        bindToSelectedButton()
        bindToItemPanned()
        bindToBlockCornerPanned()
    }
}

// MARK: - Block Renderers

extension DesignViewController {

    private func render(blockViewModels: Set<BlockViewModel>) {
        // Clears all block image views
        for (blockImageView, _) in blockViewModelsOnBoard {
            blockImageView.removeFromSuperview()
        }

        // Clears all corner image views
        for (cornerImageView, _) in blockImageViewsOnBoard {
            UIView.animate(withDuration: 0.3, animations: {
                cornerImageView.alpha = 0
            }) { _ in
                cornerImageView.removeFromSuperview()
            }
        }
        blockViewModelsOnBoard.removeAll()
        blockImageViewsOnBoard.removeAll()

        blockViewModels.forEach { [weak self] blockViewModel in
            // Creates block image view
            let blockImageView = ShapeArtist.getImageView(on: boardView, path: blockViewModel.path)
            blockImageView.transform = CGAffineTransform(rotationAngle: blockViewModel.rotationAngle)
            self?.boardView.addSubview(blockImageView)

            blockViewModelsOnBoard[blockImageView] = blockViewModel
            addUITapRecognizer(to: blockImageView, action: #selector(blockTapped(_:)))

            // Renders the corners
            renderCorners(
                blockViewModel: blockViewModel, blockImageView: blockImageView)
        }
    }

    private func renderCorners(
        blockViewModel: BlockViewModel, blockImageView: UIImageView) {
            for cornerFrame in blockViewModel.cornerFrames {
                let cornerImageView = UIImageView(frame: cornerFrame)
                cornerImageView.image = BlockViewModel.cornerImage
                cornerImageView.alpha = 1
                cornerImageView.layer.zPosition = -1
                boardView.addSubview(cornerImageView)

                addUIPanRecognizer(to: cornerImageView, action: #selector(blockCornerPanned(_:)))
                blockImageViewsOnBoard[cornerImageView] = blockImageView
            }
        }

    @objc func blockTapped(_ sender: UITapGestureRecognizer) {
        guard let blockImageView = sender.view as? UIImageView  else {
            return
        }

        guard let blockViewModel = blockViewModelsOnBoard[blockImageView] else {
            return
        }

        // Updates UI
        setupArrow(above: blockImageView)
        sizeSlider.value = Float(blockViewModel.size.width)
        rotationSlider.value = Float(blockViewModel.rotationAngle)

        // Registers selected board item
        viewModel.setSelectedBoardItem(
            boardItem: blockViewModel)
    }

    @objc func blockCornerPanned(_ sender: UIPanGestureRecognizer) {
        guard let cornerImageView = sender.view as? UIImageView else {
            return
        }

        guard let blockImageViewPanned = blockImageViewsOnBoard[cornerImageView],
              let blockViewModelPanned = blockViewModelsOnBoard[blockImageViewPanned] else {
                  return
              }

        switch sender.state {
        case .began:
            viewModel.setBlockCornerPanned(
                BlockCornerPanned(
                    origin: cornerImageView.center,
                    location: cornerImageView.center,
                    blockView: blockImageViewPanned,
                    blockViewModel: blockViewModelPanned,
                    sender: sender
                )
            )
        case .changed:
            guard let origin = viewModel.getBlockCornerPannedOrigin() else {
                return
            }

            viewModel.setBlockCornerPanned(
                BlockCornerPanned(
                    origin: origin,
                    location: sender.location(in: boardView),
                    blockView: blockImageViewPanned,
                    blockViewModel: blockViewModelPanned,
                    sender: sender
                )
            )
        case .ended:
            do {
                try viewModel.updateBlockToPannedShape()
            } catch ValidationError.invalidBlockShape {
                showBlockInvalidShapeMessage()
            } catch ValidationError.invalidSize {
                showBlockInvalidSizeMessage()
            } catch {
                Alert.showGenericError(vc: self)
            }
        default:
            break
        }
    }

    private func reshapeBlockWithPan(_ blockCornerPanned: BlockCornerPanned) {

        guard let cornerImageView = (blockCornerPanned.sender.view as? UIImageView) else {
            return
        }

        // Creates new block image view
        let newBlockImageView = ShapeArtist.getImageView(
            on: boardView, path: blockCornerPanned.newPath)
        boardView.addSubview(newBlockImageView)

        // Destroys and updates existing block image view
        blockCornerPanned.blockView.removeFromSuperview()
        blockViewModelsOnBoard[newBlockImageView] = blockCornerPanned.blockViewModel
        blockImageViewsOnBoard[cornerImageView] = newBlockImageView

    }

}

// MARK: - Peg Renderers

extension DesignViewController {

    private func render(pegViewModels: Set<PegViewModel>) {
        for (pegImageView, _) in pegViewModelsOnBoard {
            pegImageView.removeFromSuperview()
        }
        pegViewModelsOnBoard.removeAll()

        // then Redraws all pegs
        for pegViewModel in pegViewModels {
            drawPeg(pegViewModel)
        }
    }

    private func drawPeg(_ pegViewModel: PegViewModel) {
        // Creates peg image view
        let pegImage = pegViewModel.image
        let pegImageView = UIImageView(
            frame: CGRect(
                x: pegViewModel.position.x,
                y: pegViewModel.position.y,
                width: pegViewModel.diameter,
                height: pegViewModel.diameter))
        pegImageView.transform = CGAffineTransform(rotationAngle: pegViewModel.rotationAngle)
        pegImageView.image = pegImage

        // Adds recognizers to the peg image view
        addUITapRecognizer(to: pegImageView, action: #selector(pegTapped(_:)))
        addUILongPressedRecognizer(to: pegImageView, action: #selector(pegLongPressed(_:)))
        addUIPanRecognizer(to: pegImageView, action: #selector(itemPanned(_:)))

        boardView.addSubview(pegImageView)
        pegViewModelsOnBoard[pegImageView] = pegViewModel
    }

    @objc func pegLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let pegImageView = sender.view as? UIImageView else {
            return
        }

        viewModel.removePeg(at: pegImageView.center)
    }

    @objc func pegTapped(_ sender: UITapGestureRecognizer) {
        guard let pegImageView = sender.view as? UIImageView  else {
            return
        }

        guard let pegViewModel = pegViewModelsOnBoard[pegImageView] else {
            return
        }

        // Updates UI
        setupArrow(above: pegImageView)
        sizeSlider.value = Float(pegViewModel.size.width)
        rotationSlider.value = Float(pegViewModel.rotationAngle)

        // Registers selected item
        viewModel.setSelectedBoardItem(boardItem: pegViewModel)
    }

    @objc func itemPanned(_ sender: UIPanGestureRecognizer) {

        guard let itemImageView = sender.view as? UIImageView else {
            return
        }

        guard let itemViewModel: BoardItemViewModel =
                pegViewModelsOnBoard[itemImageView]
                ?? blockViewModelsOnBoard[itemImageView] else {
                    return
                }

        switch sender.state {
        case .began:
            itemImageView.layer.zPosition = 1

            // Registers item panned
            viewModel.setItemPanned(
                ItemPanned(
                    origin: itemImageView.frame.origin,
                    center: itemImageView.center,
                    pegView: itemImageView,
                    viewModel: itemViewModel,
                    location: itemImageView.frame.origin,
                    sender: sender))

        case .changed:
            guard let prevItemPanned = viewModel.getItemPanned() else {
                return
            }

            // Updates item panned
            viewModel.setItemPanned(
                ItemPanned(
                    origin: prevItemPanned.origin,
                    center: prevItemPanned.center,
                    pegView: itemImageView,
                    viewModel: itemViewModel,
                    location: itemImageView.frame.origin,
                    sender: sender))
        case .ended:
            do {

                // Updates changes to item view model
                try viewModel.updateItemToPannedLocation()
            } catch ValidationError.invalidItemLocation {
                returnViewToOrigin(viewToReturn: itemImageView)
            } catch {
                Alert.showGenericError(vc: self)
            }
        default:
            break
        }
    }

    private func returnViewToOrigin(viewToReturn: UIView) {
        guard let itemPannedOrigin = viewModel.getItemPanned()?.origin else {
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            viewToReturn.frame.origin = itemPannedOrigin
        }) { _ in
            viewToReturn.layer.zPosition = 0
        }
    }

    private func moveViewWithPan(viewToMove: UIView, sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        viewToMove.center = viewToMove.center.add(point: translation)
        sender.setTranslation(CGPoint.zero, in: view)

        setupArrow(above: viewToMove)
    }
}

// MARK: - Alert

extension DesignViewController {

    private func showDeletionConfirmMessage() {
        Alert.showConfirm(
            title: "Are you sure you want to delete this board?",
            message: "This board will be deleted immediately. You can't undo this action",
            vc: self,
            handler: handleDelete)
    }

    private func showInvalidContentHeightMessage() {
        Alert.showBasic(
            title: "Invalid height",
            message: "Please clear the items below and try again", vc: self)
    }

    private func showSaveSuccessMessage() {
        Alert.showBasic(
            title: "Successfully saved!",
            message: "", vc: self)
    }

    private func showEnterNamePrompt() {
        Alert.showBasic(title: "Please enter a name", message: "Board name should not be empty", vc: self)
    }

    private func showBlockInvalidShapeMessage() {
        Alert.showBasic(
            title: "Invalid shape",
            message: "Block should not overlap with other items or go out of bounds", vc: self)
    }

    private func showBlockInvalidSizeMessage() {
        Alert.showBasic(
            title: "Invalid size",
            message: "The block is too big", vc: self)
    }

    private func showItemInvalidSizeMessage() {
        Alert.showBasic(
            title: "Invalid size",
            message: "Item should not overlap with other items or go out of bounds", vc: self)
    }
}
