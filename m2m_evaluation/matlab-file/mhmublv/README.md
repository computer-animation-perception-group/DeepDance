# Modeling Human Motion Using Binary Latent Variables (mhmublv)

Version 1.01 

Code provided by Graham Taylor, Geoff Hinton and Sam Roweis 

For more information, see:
    http://www.cs.toronto.edu/~gwtaylor/publications/nips2006mhmublv
Permission is granted for anyone to copy, use, modify, or distribute this
program and accompanying programs and documents for any purpose, provided
this copyright notice is retained and prominently displayed, along with
a note saying that the original programs are available from our
web page.
The programs and documents are distributed without any warranty, express or
implied.  As the programs were written for research purposes only, they have
not been tested to the degree that would be advisable in any important
application.  All use of these programs is entirely at the user's own risk.

This subdirectory contains files related to learning and generation:

motiondemo.m        Main file for kearning and generation
gaussiancrbm.m      Trains CRBM with Gaussian visible units
binarycrbm.m        Trains CRBM with binary logistic visible units
paramcount.m        Counts the current CRBM parameters
weightreport.m      Visualizes parameters while learning
getfilteringdist.m  After learning the first CRBM,
                    builds minibatches for the next CRBM
gen.m               Generates data from a CRBM with one hidden layer
gen2.m              Generates data from a CRBM with two hidden layers

The Motion subdirectory contains files related to motion capture data: 
preprocessing/postprocessing, playback, etc ...

Acknowledgments

The sample data we have included has been provided by Eugene Hsu:
http://people.csail.mit.edu/ehsu/work/sig05stf/

Several subroutines related to motion playback are adapted from Neil 
Lawrence's Motion Capture Toolbox:
https://github.com/lawrennd/mocap  
which also requires https://github.com/lawrennd/ndlutil

Several subroutines related to conversion to/from exponential map
representation are provided by Hao Zhang:
http://www.cs.berkeley.edu/~nhz/software/rotations/ [Note: link is dead]

## Notes/FAQ

### How did you go from Eugene Hsu's data.zip to the data structures skel,Motion in data.mat?

The MIT data has been obtained from Eugene Hsu (see link above). There is an archive here, `data.zip` including several motions in txt format.

The `data.mat` file I provide is only a portion of the sequence `Normal1_M.txt` from this dataset.

Here's how I have generated the `{skel, Motion}` data structures in `data.mat`. In Matlab:

`M = dlmread('insert_your_path_here/Normal1_M.txt','\t');`
This reads the 108 columns in this tab-delimited text file into the Matrix, `M`. Each row represents a frame.
It also reads in a blank column, 109. So I discard it.

`M(:,109)=[];`
The meaning of the columns are described in the `readme.txt` in `data.zip`. You could replace `Normal1_M.txt` with any of the other text files.

To play this motion, with my player, you will need a skeleton. You can use the `skel` structure in my `data.mat` file. There is also a script in the `Motion/` subdirectory called `buildskel_mit.m` which demonstrates how `skel` is built.

The skeleton is not part of the data on which we train the model, but we need it to play back the motion.

It describes the hierarchy of segments, and which segments correspond to which columns of the data matrix.

Note that you can play the motion with `expPlayData.m`:

`figure(2); expPlayData(skel,M,1/120);`
Note that the data is at 120fps and it is very big so this will take a long time.
This data is extremely noisy, so I have isolated some "clean" segments.

```
Motion{1}=M(551:2300,:);
Motion{2}=M(2621:3660,:);
Motion{3}=M(3791:163000,:);
```
I have not touched the data in any other way.

### How can I use data from the CMU motion capture database with your code?

My scripts are compatible with acclaim format (I have used CMU data which is in amc/asf). I use Neil Lawrence's toolbox (see link above) to load an acclaim asf and amc file.

Just a note: I noticed that recent versions of his toolbox were giving me strange results on older versions of Matlab. It works fine for me on Matlab 7.5 or 7.6, so just a warning if the routines are giving you weird errors.

The relevant scripts are `acclaimReadSkel.m` and `acclaimLoadChannels.m` (you need to call `acclaimReadSkel.m` first as the `skel` structure needs to be passed to `acclaimLoadChannels`).

So for each sequence, this would give you `skel`, `channels`. The `skel` should be the same for multiple sequences of the same subject. Then I stick all of the channels (of varying length) into the cell array called Motion (i.e. for all ii, call `acclaimLoadChannels` and then set `Motion{ii}=channels`)

Then to use my code, `Motion` will need to be converted into exponential map form. The relevant scripts are in the `Motion/` subdirectory. Given that `skel`, `Motion` are now defined, `batchConvertCMU.m` will take each sequence in `Motion` and convert it to exponential maps via the function `euler2expmap.m`.

This will actually return `skel1`, `Motion1` and so you should just set `skel=skel1; Motion=Motion1`; (as my code expects these variable names).

Now your data should be in the right format to work with my preprocessing scripts.
