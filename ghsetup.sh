function ghsetup() {
        cd $1 && git init && echo '*.part -delta' > .gitattributes && git aac "init"
        gh repo create angg-lf/$(basename $(pwd)) --public
        git remote add origin git@github.com:angg-lf/$(basename $(pwd))
        git push -u origin main
}

