pwn-challenge.hash: Dockerfile
	docker buildx build -t ctftest_pwn_challenge --iidfile $@ .

test: pwn-challenge.hash
	docker run --privileged --rm -it -p31337:1337 ctftest_pwn_challenge:latest

.PHONY: test
