$prefix = "* ";
$branch = git branch | ? { $_.StartsWith($prefix) };
git push --set-upstream origin ($branch.Substring($prefix.Length))