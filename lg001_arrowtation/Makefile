.PHONY: all
all: frames gif

.PHONY: frames
frames:
	rm -rf ./frames
	processing-java --sketch=$(CURDIR) --force --run

NAME = $(shell basename $(CURDIR))

.PHONY: gif
gif:
	mkdir -p gif
	convert -delay 2,100 frames/*.png gif/$(NAME).gif
	convert -delay 2,100 frames/*.png -scale 128 gif/$(NAME)_small.gif
	ffmpeg -r 50 \
	       -f image2 \
	       -i frames/%03d.png \
	       -vcodec libx264 \
	       -crf 25 \
	       -pix_fmt yuv420p \
	       gif/out.mp4
