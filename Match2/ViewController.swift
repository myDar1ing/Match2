//
//  ViewController.swift
//  Match2
//
//  Created by Adilet Kenesbekov on 01.05.2025.
//

import UIKit

class ViewController: UIViewController {
  var moveCount = 0
  var secondsCount = 0
  var record : Records?

  var timer : Timer?
  var isTimeStarted = false
  @IBOutlet weak var movesLabel: UILabel!

  @IBOutlet weak var timeLabel: UILabel!

  @IBOutlet weak var recordLabel: UILabel!

  @IBOutlet weak var moveRecord: UILabel!
  
  @IBOutlet weak var timeRecord: UILabel!
  

  var images = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"].shuffled()
  var cell = [Int](repeating: 0, count: 16)
  var isClicked = false


  override func viewDidLoad() {
//    UserDefaults.standard.removeObject(forKey: "records")
    super.viewDidLoad()
    loadRecord()
    if let record = record{
      timeRecord.text = record.time
      moveRecord.text = record.moves
    }
  }

  @IBAction func toched(_ sender: UIButton) {
    print(images)
    var winCombo = [Int]()

    if cell[sender.tag - 1] != 0 || isClicked {
      return
    }

    sender.setBackgroundImage(UIImage(named: images[sender.tag-1]), for: .normal)
    sender.backgroundColor = .white
    cell[sender.tag - 1] = 1
    moveCount += 1
    movesLabel.text = String(moveCount)

    for (index, value) in cell.enumerated() {
      if value == 1 {
        winCombo.append(index)
      }
    }
    if winCombo.count == 2 {
      isClicked = true
      let one = winCombo[0]
      let two = winCombo[1]
      if images[one] == images[two] {
        cell[one] = 2
        cell[two] = 2
        isClicked = false
      }
      if isClicked {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
      }

    }

    startTimer()
    checkForWin()

  }

}

//  MARK: - EXTENSION

extension ViewController {
  @objc func clear() {
    for i in 0...15 {
      if cell[i] == 1 {
        cell[i] = 0
        let button = view.viewWithTag(i+1) as! UIButton
        button.setBackgroundImage(nil, for: .normal)
        button.backgroundColor = .systemTeal
      }
    }
    isClicked = false
  }
  func checkForWin() {
    if cell.allSatisfy({$0 == 2}){
      timer?.invalidate()
      let alert = UIAlertController(title: "You Won!", message: "To complete the game you needed \(moveCount) moves, and \(String((timeLabel.text!))) time!", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
        self.restart()
        self.timeRecord.text = self.record?.time
        self.moveRecord.text = self.record?.moves
      }))
      present(alert,animated: true)
      
//      restart()

    }

  }
  func startTimer() {
    if !isTimeStarted {
      isTimeStarted = true
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime), userInfo: nil, repeats: true)
    }
  }
  func timeString(time: TimeInterval) -> String {
      let hours = Int(time) / 3600
      let minutes = Int(time) / 60 % 60
      let seconds = Int(time) % 60
      return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
  }

  @objc func countTime() {
    secondsCount += 1
    timeLabel.text = timeString(time: TimeInterval(secondsCount))
  }

  func restart() {
    saveRecords()
    images = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"].shuffled()
    for i in 0...15 {
      cell[i] = 0
      let button = view.viewWithTag(i+1) as! UIButton
      button.setBackgroundImage(nil, for: .normal)
      button.backgroundColor = .systemTeal

    }
    moveCount = 0
    secondsCount = 0
    isTimeStarted = false
    timer?.invalidate()
    timer = nil
  }



  func saveRecords () {
    guard let move = movesLabel.text, let time = timeLabel.text else { return }

    let updatedRecord = Records(moves: move, time: time)

    if record == nil {
      do{
        let encodedData = try JSONEncoder().encode([updatedRecord])
        UserDefaults.standard.set(encodedData, forKey: "records")
      } catch{
        print("Unable to save record: \(error)")
      }
      record = updatedRecord
      return
    }

    do {
      if let data = UserDefaults.standard.data(forKey: "records") {
        var array = try JSONDecoder().decode([Records].self, from: data)
        let oldTime = convertToSeconds(record!.time)
        let newTime = convertToSeconds(updatedRecord.time)
        if newTime < oldTime || (oldTime == newTime && Int(updatedRecord.moves)! < Int(record!.moves)!) {
          array.removeAll()
          array.append(updatedRecord)
          let encodedData = try JSONEncoder().encode(array)
          UserDefaults.standard.set(encodedData, forKey: "records")
          record = updatedRecord
        }
      }
    } catch {
      print("Unable to save a record \(error)")
    }

  }

  func convertToSeconds(_ time : String) -> Int{
    let hh = Int(time.split(separator: ":")[0]) ?? 0
    let mm = Int(time.split(separator: ":")[1]) ?? 0
    let ss = Int(time.split(separator: ":")[2]) ?? 0
    return hh * 3600 + mm * 60 + ss
  }



  func loadRecord() {
      if let data = UserDefaults.standard.data(forKey: "records") {
          do {
              let array = try JSONDecoder().decode([Records].self, from: data)
              if let savedRecord = array.first {
                  record = savedRecord
              }
          } catch {
              print("Unable to load record: \(error)")
          }
      }
  }

}

