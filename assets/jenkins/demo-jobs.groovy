job('demo-verification-job') {
	description('Job that demonstrates a failed verification for VG.')
	disabled(false)
	concurrentBuild(true)
	parameters {
		stringParam("SCM_BRANCH","master","Protected branch")
		stringParam("json", null, "Request type?")
		stringParam("committer", null, "Developer that pushed the commit to remote.")
		stringParam("protected", null, "SCM_BRANCH is protected?")
		stringParam("parent", null, "SHA of parent commit.")
		stringParam("longid", null, "SHA of commit?")
	}
    steps {
        shell('echo "job failed!" && exit -1')
    }
}