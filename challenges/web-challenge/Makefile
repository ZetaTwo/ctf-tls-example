web-challenge.hash: Dockerfile
	docker buildx build -t ctftest_web_challenge --iidfile $@ .

test: pwn-challenge.hash
	docker run --rm -it -p31337:1337 ctftest_web_challenge:latest

publish:
	docker tag ctftest_web_challenge:latest localhost:5001/ctftest_web_challenge:latest
	docker push localhost:5001/ctftest_web_challenge:latest

.PHONY: test publish
