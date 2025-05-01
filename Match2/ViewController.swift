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

  var timer : Timer?
  var isTimeStarted = false
  @IBOutlet weak var movesLabel: UILabel!

  @IBOutlet weak var timeLabel: UILabel!


  var images = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"].shuffled()
  var cell = [Int](repeating: 0, count: 16)
  var isClicked = false


  override func viewDidLoad() {
    super.viewDidLoad()
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
    movesLabel.text = "Moves : " + String(moveCount)

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
        self.movesLabel.text = "Moves : 0"
        self.timeLabel.text = "00:00:00"
      }))
      present(alert,animated: true)
      restart()

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
    images = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"].shuffled()
    for i in 0...15 {
      cell[i] = 0
      let button = view.viewWithTag(i+1) as! UIButton
      button.setBackgroundImage(nil, for: .normal)
      button.backgroundColor = .systemTeal
      moveCount = 0
      secondsCount = 0
      timer = nil
      isTimeStarted = false
    }
  }

}

