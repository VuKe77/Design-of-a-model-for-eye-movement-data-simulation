
# Design of a model for eye movement data simulation
The initial version of the presented algorithm was developed for the Bachelor Thesis titled "Design of a model for eye movement data simulation" authored by Vukašin Spasojević and defended under the mentorship of [Assoc. Prof. Nadica Miljković](https://www.etf.bg.ac.rs/en/faculty/staff/nadica-miljkovic-4323) on August 27, 2024 at the [University of Belgrade - School of Electrical Engineering](https://www.etf.bg.ac.rs/en).

## GitHub Repository Contents

### Code
Shared programs are free software: you can redistribute them and/or modify them under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. These programs are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with these programs. If not, see [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/).

Please, report any bugs to the Authors listed in the Contacts.
The repository contains the following code:

1) [saccade_detection.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/saccade_detection.m) - MATLAB code for saccade detection and extraction of statistical features.
2) [model_fitting.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/model_fitting.m) - MATLAB code for Code for statistical processing of signal parameters of interest, modeling their distributions and modeling main sequences of saccadic eye movements.
3) [simulate_signal.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/simulate_signal.m) - MATALB code for simulating eye movement signal.
4) [trajectory_fit.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/trajectory_fit.m) - MATLAB code for fitting a saccade trajectory using Hill's equation.
5) [signal_generation.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/signal_generation.m) - MATLAB code for generating a simulated eye movement signal, followed by applying a detection algorithm to the simulated signal.
6) [remove_impulse_noise.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/remove_impulse_noise.m) - MATLAB code for removing impulse noise from a raw signal (downloaded from the GazeBase data repository [[1](https://doi.org/10.1038/s41597-021-00959-y)-[2](https://doi.org/10.6084/m9.figshare.12912257)]).
7) [modelPeak.mat](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/modelPeak.mat) - MAT file containing the main sequence model (relationship between saccade amplitude and peak velocity).
8) [modelDuration.mat](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/modelDuration.mat) - MAT file containing the main sequence model (relationship between saccade amplitude and duration).
9) [gazePDF.mat](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/gazePDF.mat) - MAT file containing a model of the fixation duration distribution.
10) [ampPDF.mat](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/ampPDF.mat) - MAT file containing a model of the saccade amplitude distribution.
11) [MA_filter.mat](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/MA_filter.m) - MATLAB code for performing moving average filtering of a signal.
12) [central_diff.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/central_diff.m) - MATLAB code for calculating the first derivative of a signal using the central difference method.
13) [find_indices.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/find_indices.m) - MATLAB code that finds the indices of values in y that are closest to each value in x.
14) [hist_normal.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/hist_normal.m) - MATLAB code for calculating and plotting histogram of the signal.
15) [EXPONENTIAL.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/EXPONENTIAL.m) - MATLAB code for exponential model.
16) [SQRT.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/SQRT.m) - MATLAB code for sqrt model.
17) [FIXED_SQRT.m](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/FIXED_SQRT.m) - MATLAB code for fixed_sqrt model.
18) [LICENSE file](https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation/blob/master/LICENSE) - containing GNU General Public License v3.0

### Disclaimer
The MATLAB code is provided without any guarantee and it is not intended for medical purposes.

## References
1) Griffith, H., Lohr, D., Abdulin, E., & Komogortsev, O. (2021). GazeBase, a large-scale, multi-stimulus, longitudinal eye movement dataset. Scientific Data, 8(1), 184. [https://doi.org/10.1038/s41597-021-00959-y](https://doi.org/10.1038/s41597-021-00959-y)
2) Griffith, H., Lohr, D. & Komogortsev, O. V. GazeBase data repository. figshare [https://doi.org/10.6084/m9.figshare.12912257](https://doi.org/10.6084/m9.figshare.12912257) (2021).

## How to cite this repository?
If you find provided code useful for your own research and teaching class, please cite the following references:
1) V. Spasojević, S. Stokanović, I. Tanasković, J. Sodnik, N. Miljković, "Design of a model for eye movement data simulation", GitHub repository, https://github.com/VuKe77/Design-of-a-model-for-eye-movement-data-simulation, 2024.

## Contact
Vukašin Spasojević ([spasojevic.vukasin8@gmail.com](mailto:spasojevic.vukasin8@gmail.com))
