import librosa, math, os, json
import numpy as np

data_path = "./dataset/music_feature/librosa/samples/"
motion_frequency = 30.0
window_frequency = 100

def save_to_csv(data, filename):
    T = data.shape[0]
    D = data.shape[1]

    f = open(filename, 'w')
    for i in range(T):
        st = ''
        for k in range(D):
            st += str(data[i, k]) + ','
        st = st[:-1]
        f.write(st + '\n')
    f.close()

sample_list = []
for fname in sorted(os.listdir(data_path)):
    filename = os.path.join(data_path, fname)
    out_filename = fname.replace(".wav",".csv")
    if os.path.exists(os.path.join(data_path, out_filename)):
        continue    
    print(filename)

    y, sr = librosa.load(filename,sr=None)
    y = y[441000*2:]

    frames = math.floor(motion_frequency*len(y)/sr)

    num_per_frame = sr/motion_frequency
    num_per_window = sr // window_frequency
    window_stride = num_per_window // 2
    seg_feature = []
    for i in range(frames):
        frame_music_seq = y[round(i * num_per_frame):round((i + 1) * num_per_frame)]
        start = 0
        j = 0
        windows_feature = []
        while start + num_per_window <= len(frame_music_seq):
            music_seq = frame_music_seq[start:start + num_per_window]
            start += window_stride
            j += 1
            frame_feature = []

            centroid = librosa.feature.spectral_centroid(music_seq,sr,n_fft=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(centroid[:,0])

            bandwidth = librosa.feature.spectral_bandwidth(music_seq,sr,n_fft=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(bandwidth[:, 0])

            rolloff = librosa.feature.spectral_rolloff(music_seq,sr,n_fft=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(rolloff[:, 0])

            poly_feature_2 = librosa.feature.poly_features(music_seq,sr,n_fft=len(music_seq),hop_length=len(music_seq),order=1)
            frame_feature.extend(poly_feature_2[:, 0])

            poly_feature_3 = librosa.feature.poly_features(music_seq, sr, n_fft=len(music_seq), hop_length=len(music_seq),order=2)
            frame_feature.extend(poly_feature_3[:, 0])

            mfcc =librosa.feature.mfcc(music_seq,sr,n_mfcc=13)
            frame_feature.extend(mfcc[:, 0])

            mel_spec = librosa.feature.melspectrogram(music_seq, sr, n_fft=len(music_seq), hop_length=len(music_seq))
            frame_feature.extend(mel_spec[:, 0])

            mfcc_delta_1 = librosa.feature.delta(mfcc,axis =0,order=1)
            frame_feature.extend(mfcc_delta_1[:, 0])

            mfcc_delta_2 = librosa.feature.delta(mfcc,axis=0, order=2)
            frame_feature.extend(mfcc_delta_2[:, 0])

            chroma_cens = librosa.feature.chroma_cens(music_seq,sr)
            frame_feature.extend(chroma_cens[:, 0])

            chroma_stft = librosa.feature.chroma_stft(music_seq,sr,n_fft=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(chroma_stft[:, 0])

            zero_crossing  = librosa.feature.zero_crossing_rate(music_seq,frame_length=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(zero_crossing[:, 0])

            rmse = librosa.feature.rmse(music_seq,frame_length=len(music_seq),hop_length=len(music_seq))
            frame_feature.extend(rmse[:, 0])

            frame_feature = np.reshape(frame_feature,[1,len(frame_feature)])
            if len(windows_feature) == 0:
                windows_feature = frame_feature
            else:
                windows_feature = np.concatenate((windows_feature,frame_feature))
        windows_feature = np.reshape(windows_feature,[1,-1])
        if len(seg_feature) == 0:
            seg_feature = windows_feature
        else:
            seg_feature = np.concatenate((seg_feature,windows_feature))

    save_to_csv(seg_feature, os.path.join(data_path, out_filename))
    sample_list.append(os.path.join("samples", out_filename))

with open("sample_list.json", "w") as f:
    json.dump(sample_list, f)