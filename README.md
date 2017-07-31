# cocoapods-store

cocoapods-store is a plugin that lets you load push and pull dependencies to
and from an s3 bucket.

Pushes are keyed against the commit they are linked to the commit allowing them
to be pulled on demand.

This provides a faster alternative to pulling repos separately when running
pod install or pod update.

This gives several benefits:

 - Pods only have to be installed once for the given commit avoiding multiple
   requests to Github and other stores for subsequent installs
 - Continuous integration agents can pull from the store helping to decrease
   build times

## Installation
```bash
    $ gem install cocoapods-store
```
## Usage

```bash
	$ pod store push --bucket "my-pod-store" --aws-key "KEY" --aws-secret "SECRET"

	$ pod store pull --bucket "my-pod-store" --aws-key "KEY" --aws-secret "SECRET"
```

It is recommended that you create a `.cocoapods-store.yml` rather than passing
arguments. The yaml should have the following format:

```yaml
bucket: "my-pod-store"
aws-key: "KEY"
aws-secret: "SECRET"
```

With a yaml file in place, you can simply call:

```bash
	$ pod store push

	$ pod store pull
```

## Roadmap

- [x] S3 support
- [ ] Implicit Installation
- [ ] Cache built frameworks
