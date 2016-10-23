# scan
A docker container that produces searchable PDFs from ADF scanners. Uses SANE; tesseract, and pdftk to generate a multi-page PDF.

#### Features
- Based on Debian unstable
- SANE
- Tesseract with English, German, French, Italian language packs
- pdftk
- OpenJDK JRE
- jhove pdf validation

#### Environment variables
- **USERID**: The owner UID of the generated file

#### Volumes
- **/var/scan**: the output directory

#### Ports
- None

#### Usage
- Scan a document
 - docker run --rm --device=/dev/bus/usb/001/009 -v /home/user/files:/var/scan phbaer/scan -e USERID=1000 /usr/local/bin/scan.sh file.pdf "Title" "Subject" "Author"
- Open a shell
 - docker run --rm -ti phbaer/scan /bin/bash
- Simple get.sh script
 - get.sh $PWD/files file.pdf "Title" "Subject" "Author"

#### Known issues
