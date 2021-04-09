
在vim的配置文件.vimrc中进行配色方案的设置：

	set t_Co=256 " required
	colorscheme evening

不过有时候我们对于自带的配色方案不太满意，那要怎么自己安装一些配色方案呢？主要分三步：

1. 在当前用户目录 ~/ 下的 .vim 目录(如果没有，mkdir ~/.vim进行新建该目录)。在 ~/.vim/ 下新建一个叫 colors 的目录，我们下一步下载的配色方案.vim文件便放到该目录下。

2. 将本文件夹内的colors文件中你想要的配色方案拷贝到~/.vim/colors目录下面。

3. 从中选出一个配色方案，比如molokai的配色方案, 修改~/.vimrc 配置文件如下:

	set t_Co=256 " required
	colorscheme molokai
