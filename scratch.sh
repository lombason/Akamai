 mkdir -p ~/.ssh/


 jlomba@bos-mpfft .ssh %  mkdir -p ~/.ssh/{internal,external,protected,deployed}

 for key in {internal,external,deployed,protect}; do ssh-keygen -t rsa -b 2048 -C "$USER-$key-`date +%Y-%m-%d`" -f ~/.ssh/$USER-$key-`date +%Y-%m-%d`; done

  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/jlomba/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"


    source "`brew --prefix grc`/etc/grc.bashrc"
