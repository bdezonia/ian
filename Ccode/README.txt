How to build extensions for Image*.so

  You must have first installed MS Visual Studio 6.0 Professional. As of
  version 1.8.6-26 Ruby requires this version for its C extensions on Windows.
  This program will not run on Vista. XP and 2003 Server can both host it. So
  I make my source changes on a Vista box but then I remote to a 2003 server
  box that has the compiler installed and I compile on a mapped network drive
  back to the original source.

  You may need to edit initmake.bat and make.bat to reflect the correct paths
  to your MS tools.

  Then from a command prompt in this directory do:
    initmake
    makeall

  Then copy *.so into your Ian distribution directory so that they will get
  into an Ian.zip for release or testing.

How this scheme was created

  The makefiles were created by running extconf.rb and substituting the correct
  extension name in the code (such as Image1, Image16, etc.). Then naming those
  makefiles with the extension 1, 4, 8, 16, and 24.

  Then I edited up the batch files so everything could live in one directory.
