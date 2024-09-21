

**Description**:  
WaveAssembly is a collection of MIPS assembly programs designed for analyzing and manipulating `.wav` audio files at the byte level. These programs are capable of interpreting wave file headers, analyzing audio data, and performing operations on sound files, such as reversing audio. The repository contains the following programs:

### Programs

1. **hearder_interpretation.asm**  
   This program reads the header of a `.wav` file and outputs key details such as the number of channels, sample rate, byte rate, and bits per sample. It prompts the user for the file's full path and size (in bytes).

2. **AudioDataAnalysis.asm**  
   This program scans through the audio data of a `.wav` file to determine the maximum and minimum amplitude values (the highest and lowest audio sample values). The user is prompted to input the file path and size.

3. **SoundEffect.asm**  
   This program reverses the audio data in a `.wav` file and outputs the reversed audio to a new file. It requires the user to specify both the input and output file paths, as well as the file size.

Each program serves as a practical demonstration of handling binary file formats and processing raw audio data in assembly language, providing a deep understanding of both the `.wav` file structure and MIPS programming.
