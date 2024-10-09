
resource "aws_iam_policy" "create" {
  for_each    = { for role in var.roles : role.name => role }
  name        = "${replace(join("-", [for part in split("-", each.value.name) : title(part)]), "-", "")}Policy"
  description = "Policy - ${each.value.description}"
  policy      = each.value.policy
}

resource "aws_iam_role" "create" {
  for_each           = { for role in var.roles : role.name => role }
  name               = "${replace(join("-", [for part in split("-", each.value.name) : title(part)]), "-", "")}Role" #Remove hyphen and make upper case first chars and join all words ex: Ec2InstanceS3ConnectRole
  assume_role_policy = each.value.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  for_each   = { for role in var.roles : role.name => role }
  policy_arn = aws_iam_policy.create[each.key].arn
  role       = aws_iam_role.create[each.key].name
}

output "roles" {
  value = zipmap(values(aws_iam_role.create).*.name, values(aws_iam_role.create).*.arn)
}