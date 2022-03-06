//
//  PlayViewController.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

class PlayViewController: UIViewController {

    @IBOutlet private var cannonImageView: UIImageView!
    @IBOutlet private var boardScrollView: UIScrollView!
    @IBOutlet private var boardView: UIView!

    @IBOutlet private var boardViewHeight: NSLayoutConstraint!

    private let userDefaults = UserDefaults.standard

    private var pegImageViews = Set<UIImageView>()
    private var blockImageViews = Set<UIImageView>()
    private var ballImageView: UIImageView?
    private var bucketImageView: UIImageView?
    private var bucketTopImageView: UIImageView?

    @IBOutlet private var scoreTotalLabel: UILabel!
    @IBOutlet private var ballsTotalLabel: UILabel!
    @IBOutlet private var ballsLeftLabel: UILabel!
    @IBOutlet private var orangePegsTotalLabel: UILabel!
    @IBOutlet private var orangePegsLeftLabel: UILabel!

    var rainbowParticleEmitter: ParticleEmitter?
    var viewModel = PlayViewModel(boardViewModel: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playBackgroundMusic()

        setupViews()
        setupBinders()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismisses view when board is not yet loaded
        guard viewModel.isBoardViewModelLoaded else {
            dismiss(animated: true, completion: nil)
            return
        }

        setupParticleEmitter()
        setupRecognizers()
    }

    override func viewDidLayoutSubviews() {
        setPlayBoardViewModelBounds()
    }

    private func setPlayBoardViewModelBounds() {
        viewModel.setPlayBoardViewModelBounds(
            boardScrollView.bounds)
    }

    @IBAction private func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func setPlayViewModel(boardViewModel: BoardViewModel) {
        viewModel = PlayViewModel(
            boardViewModel: PlayBoardViewModel(
                boardViewModel: boardViewModel))
    }

}

// MARK: - Setup

extension PlayViewController {
    private func setupRecognizers() {
        addUIPanRecognizer(to: boardView, action: #selector(itemPanned(_:)))
        addUITapRecognizer(to: boardView, action: #selector(boardViewTapped(_:)))
    }

    private func setupParticleEmitter() {
        self.rainbowParticleEmitter = ParticleEmitter(
            on: self.boardView,
            particleImage:
                #imageLiteral(resourceName: "snow"))
    }

}

// MARK: - Setup binders

extension PlayViewController {

    private func bindToActivatedPowerup() {
        viewModel.activatedPowerup.bind { [weak self] activatedPowerup in
            switch activatedPowerup {
            case .kaboom:
                self?.playExplodeSoundEffect()
            case .spookyBall:
                self?.playSpookySoundEffect()
            default:
                break
            }
        }
    }

    private func bindToCollisionContact() {
        viewModel.collisionContact.bind { [weak self] contact in
            guard let contact = contact else {
                return
            }

            let collisionCheckBits = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

            if collisionCheckBits == ColliderType.ball | ColliderType.peg {
                self?.playPegSoundEffect()
            }

            if collisionCheckBits == ColliderType.ball | ColliderType.block {
                self?.playBlockSoundEffect()
            }

            if collisionCheckBits == ColliderType.ball | ColliderType.bucket {
                self?.playBucketSoundEffect()
            }
        }
    }

    private func bindToGameStats() {
        viewModel.bindToGameStats { [weak self] gameStats in
            guard let self = self else {
                return
            }

            let ballsLeft = gameStats.ballsLeft
            let orangePegsLeft = gameStats.orangePegsLeft

            self.orangePegsLeftLabel.text = String(gameStats.orangePegsLeft)
            self.orangePegsTotalLabel.text = String(gameStats.orangePegsTotal)
            self.ballsLeftLabel.text = String(gameStats.ballsLeft)
            self.ballsTotalLabel.text = String(gameStats.ballsTotal)
            self.scoreTotalLabel.text = String(gameStats.scoreTotal)

            if ballsLeft <= 0, orangePegsLeft > 0 {
                self.playLoseSoundEffect()
                self.showLoseMessage()
                return
            }

            if orangePegsLeft <= 0, ballsLeft >= 0 {
                self.playWinSoundEffect()
                self.showWinMessage()
                return
            }
        }
    }

    private func bindToBucketViewModels() {
        viewModel.bindToBucketViewModel { [weak self] bucketViewModel in
            guard let bucketViewModel = bucketViewModel else {
                return
            }

            self?.handleBucketViewModelUpdate(bucketViewModel: bucketViewModel)
        }

    }

    private func bindToContentHeight() {
        viewModel.bindToContentHeight { [weak self] contentHeight in
            DispatchQueue.main.async {
                self?.boardViewHeight.constant = contentHeight
            }
        }
    }

    private func bindToBallViewModel() {
        viewModel.bindToBallViewModel { [weak self] ballViewModel in
            guard let ballViewModel = ballViewModel else {
                return
            }

            self?.handleBallViewModelUpdate(ballViewModel: ballViewModel)
            self?.updateCannonImageView()
        }
    }

    private func bindToBlockViewModel() {
        viewModel.bindToBlockViewModels { [weak self] blockViewModels in
            self?.render(blockViewModels: Set(blockViewModels.values))
        }
    }

    private func bindToPegViewModels() {
        viewModel.bindToPegViewModels { [weak self] pegViewModels in
            self?.render(pegViewModels: Set(pegViewModels.values))
        }
    }

    private func bindToRotationAngle() {
        viewModel.bindToRotationAngle { [weak self] rotationAngle in
            self?.cannonImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }

    private func setupBinders() {
        guard viewModel.isBoardViewModelLoaded else {
            return
        }

        bindToActivatedPowerup()
        bindToCollisionContact()
        bindToGameStats()
        bindToBucketViewModels()
        bindToContentHeight()
        bindToBallViewModel()
        bindToBlockViewModel()
        bindToPegViewModels()
        bindToRotationAngle()
    }

}

// MARK: - Setup Views

extension PlayViewController {
    private func setupViews() {
        setupCannonImageView()
    }

    private func setupCannonImageView() {
        let anchorY = userDefaults.double(forKey: "cannonAnchorY")
        self.cannonImageView.setAnchorPoint(
            anchorPoint: CGPoint(x: 0.5, y: anchorY))
    }

    private func setupBucketImageView(bucketViewModel: BucketViewModel) {
        bucketImageView = UIImageView(frame: bucketViewModel.frame)
        bucketTopImageView = UIImageView(frame: bucketViewModel.frame)

        guard let bucketImageView = bucketImageView,
              let bucketTopImageView = bucketTopImageView else {
                  return
              }

        bucketImageView.image = BucketViewModel.normalImage
        bucketImageView.layer.zPosition = -2
        boardView.addSubview(bucketImageView)

        bucketTopImageView.image = BucketViewModel.normalImageTop
        bucketTopImageView.layer.zPosition = 1
        boardView.addSubview(bucketTopImageView)
    }

}

// MARK: - Renderers

extension PlayViewController {

    private func updateCannonImageView() {
        cannonImageView.image = viewModel.getCannonImage()
    }

    private func handleBucketViewModelUpdate(bucketViewModel: BucketViewModel) {
        if bucketImageView == nil || bucketTopImageView == nil {
            setupBucketImageView(bucketViewModel: bucketViewModel)
        }

        updateBucketImageView(bucketViewModel: bucketViewModel)
    }

    private func updateBucketImageView(bucketViewModel: BucketViewModel) {
        bucketImageView?.frame = bucketViewModel.frame
        bucketTopImageView?.frame = bucketViewModel.frame

        if bucketViewModel.containsBall {
            emitParticlesUpwards(at: bucketViewModel.midPosition)
        }
    }
}

// MARK: - Item Renderers

extension PlayViewController {
    private func render(blockViewModels: Set<PlayBlockViewModel>) {
        // Clears existing blocks
        for blockImageView in blockImageViews {
            blockImageView.removeFromSuperview()
        }
        blockImageViews.removeAll()

        // then Draws new blocks
        blockViewModels.forEach { [weak self] blockViewModel in
            let blockImageView = ShapeArtist.getImageView(on: boardView, path: blockViewModel.path)
            self?.boardView.addSubview(blockImageView)
            blockImageViews.insert(blockImageView)
        }
    }

    private func render(pegViewModels: Set<PlayPegViewModel>) {
        for pegImageView in pegImageViews {
            pegImageView.removeFromSuperview()
        }
        pegImageViews.removeAll()

        // then Redraws all pegs
        for pegViewModel in pegViewModels {
            let isLitPegAfterReload = !viewModel.isBallLaunched && pegViewModel.isLit
            let shouldRemoveAfterDraw = isLitPegAfterReload
            || pegViewModel.shouldPopPrematurely

            drawPegOnView(
                pegViewModel,
                removeAfterDraw: shouldRemoveAfterDraw
            )
        }
    }

    private func drawPegOnView(_ pegViewModel: PlayPegViewModel, removeAfterDraw: Bool = false) {

        let pegImage = pegViewModel.image
        let pegImageView = UIImageView(
            frame: CGRect(
                x: pegViewModel.position.x,
                y: pegViewModel.position.y,
                width: pegViewModel.diameter,
                height: pegViewModel.diameter))

        pegImageView.image = pegImage
        boardView.addSubview(pegImageView)

        renderPowerup(pegViewModel: pegViewModel)

        if removeAfterDraw {
            removePegFromView(pegImageView: pegImageView)
        } else {
            pegImageViews.insert(pegImageView)
        }
    }

    private func renderPowerup(pegViewModel: PlayPegViewModel) {
        guard pegViewModel.isLit, !pegViewModel.isPowerupRendered else {
            return
        }

        if pegViewModel.pegType == .green {
            emitParticles(around: pegViewModel.center)
            pegViewModel.isPowerupRendered = true
        }
    }

    private func removePegFromView(pegImageView: UIImageView) {
        viewModel.removePeg(at: pegImageView.center)
        // Animates dissapearance
        UIView.animate(withDuration: 1.0, animations: { pegImageView.alpha = 0
        }, completion: { _ in
            DispatchQueue.main.async {
                pegImageView.removeFromSuperview()
            }
        })
    }

}

// MARK: - Ball Renderers

extension PlayViewController {

    private func handleBallViewModelUpdate(ballViewModel: BallViewModel) {
        updateBallImageView(ballViewModel: ballViewModel)
        scrollToBall(ballViewModel: ballViewModel)

    }

    private func updateBallImageView(ballViewModel: BallViewModel) {
        let newBallImageView = UIImageView(frame: ballViewModel.frame)
        newBallImageView.image = BallViewModel.image
        newBallImageView.layer.zPosition = -1
        ballImageView?.removeFromSuperview()
        boardView.addSubview(newBallImageView)
        ballImageView = newBallImageView

        if viewModel.isSpookyModeOn {
            ballImageView?.alpha = 0.5
        }
    }

    private func scrollToBall(ballViewModel: BallViewModel) {
        let contentOffset = viewModel.getContentOffset()
        let isBallAtTop = ballViewModel.center.y == 0
        boardScrollView.setContentOffset(contentOffset, animated: isBallAtTop)
    }
}
