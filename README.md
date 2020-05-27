# DeepDance: Music-to-Dance Motion Choreography with Adversarial Learning
This reop contains code of paper on Music2Dance generation: "[DeepDance: Music-to-Dance Motion Choreography with Adversarial Learning](https://ieeexplore.ieee.org/abstract/document/9042236/)". [Project Page](http://zju-capg.org/deepdance.html)

## Requirements
- A CUDA compatible GPU
- Ubuntu >= 14.04

## Usage
- **Setup**

  Download this repo on your computer and create a new enviroment using commands as follows:
  ```
  git clone https://github.com/computer-animation-perception-group/DeepDance.git
  conda create -n music_dance python==3.5
  pip install -r requirement.txt
  ```
  Put your audio files (.wav) under "./dataset/music_feature/librosa/samples"

  Extract low-level musical features using command as follows:
  ```
  python music_feature_extract.py
  ```
  Run the following command to generate dance sequences
  ```
  sh generate_dance.sh
  ```
  Generated dances are in "training_results/motions". You can change folders of generated dances by changing last line of "generate_dance.sh".
- **Dataset**

  Datas will be released soon.
- **Training**

  Training code will be released soon
- **Trained Models**

   Trained models of multiple dancing genres are on [GoogleDrive](https://drive.google.com/drive/u/1/folders/1a3-bf2N-TdzgVBqaAdRRKsWuicqKlTGK).

  Download these models and put them on "./training_results/models".

  You can generate dance sequences of different genres by changing model_path in "generate_dance.sh".

- **Visualization**

  Open matlab and set path to "m2m_evaluation" folder and run csv_visualization.m

## License
Licensed under an GPL v3.0 License.

## Bibtex
```
@article{sun2020deepdance,
  author={G. {Sun} and Y. {Wong} and Z. {Cheng} and M. S. {Kankanhalli} and W. {Geng} and X. {Li}},
  journal={IEEE Transactions on Multimedia}, 
  title={DeepDance: Music-to-Dance Motion Choreography with Adversarial Learning}, 
  year={2020},
  volume={},
  number={},
  pages={1-1},}
```