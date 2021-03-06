//
//  LabelListViewController.swift
//  IssueTracker
//
//  Created by A on 2020/11/03.
//!
import UIKit

class LabelListViewController: UIViewController {
    
    // MARK: - @IBOutlet Properties
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func showPopUp(_ sender: UIBarButtonItem) {
        presentAsPopUp(senderType: .label) { [weak self] in
            self?.dataSourceUpdateFromNetwork()
        }
    }
    
    // MARK: - Properties
    var dataSource: UICollectionViewDiffableDataSource<Section, Label>!
    private let api = NetworkManager()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(navigationBar)
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSourceUpdateFromNetwork()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LabelListCell, Label> { (cell, indexPath, label) in
            cell.updateWithLabel(label)
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Label>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, label) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: label)
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self]
            (indexPath) in
            guard let self = self else { return nil }
            guard let label = self.dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            return self.trailingSwipeActionConfigurationForListCellItem(label)
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func dataSourceUpdateFromNetwork() {
        let api = NetworkManager()
        let parameters: Label? = nil
        api.request(type: RequestType(endPoint: "label", method: .get, parameters: parameters)) { [weak self] (data: [Label]) in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Label>()
            snapshot.appendSections([.main])
            snapshot.appendItems(data)
            self?.dataSource.apply(snapshot)
        }
    }
    
    func trailingSwipeActionConfigurationForListCellItem(_ label: Label) -> UISwipeActionsConfiguration? {
        let deleteParameters: Label? = nil
        let deleteRequestType = RequestType(endPoint: "label",
                                            method: .delete,
                                            parameters: deleteParameters,
                                            id: label.id)
        let deleteAction = createAction(title: "Delete",
                                        requestType: deleteRequestType,
                                        response: UpadateResponse(numOfaffectedRows: 0) )
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func createAction<T: Codable, U: Codable> (title: String,
                                                       requestType: RequestType<T>,
                                                       response: U) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: title) {
            [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            let alert = UIAlertController(title: "삭제하시겠습니까?", message: "이 작업은 되돌릴 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler : { _ in
                                            self.api.request(type: requestType) { [weak self] (data: U) in
                                                print(data)
                                                self?.dataSourceUpdateFromNetwork()
                                            }})
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
            alert.addAction(cancel)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            
            completion(true)
        }
        return action
    }
}

extension LabelListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
