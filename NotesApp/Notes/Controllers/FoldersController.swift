import UIKit

var noteFolders = [NoteFolder]()

class FoldersController: UITableViewController {
    
    fileprivate let CELL_ID: String = "CELL_ID"
    
    fileprivate let headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 15, width: 100, height: 20))
        label.text = "ICLOUD"
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .darkGray
        headerView.addBorder(toSide: .bottom, withColor: UIColor.lightGray.withAlphaComponent(0.5).cgColor, andThickness: 0.3)
        headerView.addSubview(label)
        return headerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Folders"
        
        noteFolders = CoreDataManager.shared.fetchNoteFolders()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        let items:[UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "New Folder", style: .done, target: self, action: #selector(self.handleAddNewFolder))
        ]
        
        self.toolbarItems = items
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        self.navigationItem.setRightBarButton(editButton, animated: false)
        self.navigationController?.toolbar.tintColor = .primaryColor
        self.navigationController?.navigationBar.tintColor = .primaryColor
        
        setupTranslucentViewa()
        
        self.tableView.reloadData()
    }
    
    var textField: UITextField!
    
    @objc func handleAddNewFolder() {
        let addAlert = UIAlertController(title: "New Folder", message: "Enter name for this folder.", preferredStyle: .alert)
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            addAlert.dismiss(animated: true)
        }))
        
        addAlert.addTextField { (tf) in
            self.textField = tf
        }
        
        addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            addAlert.dismiss(animated: true)
            
            guard let title = self.textField.text else { return }
            let newFolder = CoreDataManager.shared.createNoteFolder(title: title)
            noteFolders.append(newFolder)
            self.tableView.insertRows(at: [IndexPath(row: noteFolders.count - 1, section:  0)], with: .fade)
        }))
        
        present(addAlert, animated: true)
    }
        
    fileprivate func setupTableView() {
        tableView.register(FolderCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.tableHeaderView = headerView
    }
    
    fileprivate func getImage(withColor color:UIColor, andSize size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        return image
    }
    
    fileprivate func setupTranslucentViewa() {
        let toolBar = self.navigationController?.toolbar
        let navigationBar = self.navigationController?.navigationBar
        
        let slighWhite = getImage(withColor: UIColor.white.withAlphaComponent(0.9), andSize: CGSize(width: 30, height: 30))
        
        toolBar?.setBackgroundImage(slighWhite, forToolbarPosition: .any, barMetrics: .default)
        toolBar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        navigationBar?.setBackgroundImage(slighWhite, for: .default)
        navigationBar?.shadowImage = slighWhite
    }
}

extension FoldersController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteFolders.count
    }
    
    override func tableView(_ tablewView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablewView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! FolderCell
        let folderForRow = noteFolders[indexPath.row]
    
        cell.folderData = folderForRow
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderNotesController = FolderNotesController()
        let folderForRowSelected = noteFolders[indexPath.row]
        folderNotesController.folderData = folderForRowSelected
        navigationController?.pushViewController(folderNotesController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            let noteFolder = noteFolders[indexPath.row]
            
            if CoreDataManager.shared.deleteNoteFolder(noteFolder: noteFolder) {
                noteFolders.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        return [deleteAction]
    }
}
