# 🎬 Lab 1: Netflix Git Workflow Mastery

> **Master Git like Netflix engineers handle 1000+ daily deployments**

## 🎯 Lab Objectives

By the end of this lab, you'll:
- ✅ Implement Netflix's branching strategy
- ✅ Handle complex merge conflicts
- ✅ Recover from git disasters
- ✅ Automate workflow with hooks

**⏱️ Estimated Time**: 30 minutes  
**🎚️ Difficulty**: Beginner  
**🏆 XP Reward**: 100 points

---

## 📚 Background: Netflix's Git Strategy

**Netflix Challenge**: 2,000+ engineers, 1000+ daily deployments, zero downtime

### 🎬 **The Netflix Way**
```
Production Branch Strategy:
├── main (production-ready)
├── develop (integration)
├── feature/* (new features)
├── hotfix/* (emergency fixes)
└── release/* (release preparation)
```

**Real Stats**:
- 🚀 **Deployments**: 1000+ per day
- 👥 **Engineers**: 2000+ contributors
- 🔄 **Merge Rate**: 99.9% success
- ⚡ **Recovery Time**: < 5 minutes

---

## 🛠️ Lab Setup

### 📋 **Prerequisites**
```powershell
# Verify Git installation
git --version

# Configure Git (if not done)
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

### 🎮 **Lab Environment**
```powershell
# Create lab workspace
mkdir netflix-git-lab
cd netflix-git-lab

# Initialize repository
git init
echo "# Netflix Microservice" > README.md
git add README.md
git commit -m "Initial commit"
```

---

## 🎯 Challenge 1: Netflix Branching Strategy

### 🎬 **Scenario**: You're a Netflix engineer working on the recommendation engine

```powershell
# Create develop branch
git checkout -b develop

# Create feature branch
git checkout -b feature/recommendation-algorithm

# Simulate development work
echo "class RecommendationEngine:" > recommendation.py
echo "    def suggest_movies(self, user_id):" >> recommendation.py
echo "        # Netflix magic happens here" >> recommendation.py
echo "        return ['Stranger Things', 'The Crown']" >> recommendation.py

git add recommendation.py
git commit -m "feat: add basic recommendation algorithm"
```

### 🎯 **Task 1.1**: Implement Feature Development
```powershell
# Add more features
echo "    def trending_content(self):" >> recommendation.py
echo "        return ['Wednesday', 'Glass Onion']" >> recommendation.py

git add recommendation.py
git commit -m "feat: add trending content feature"

# Push feature branch
git push -u origin feature/recommendation-algorithm
```

### ✅ **Validation 1.1**
```powershell
# Check branch structure
git branch -a
# Should show: main, develop, feature/recommendation-algorithm
```

---

## 🎯 Challenge 2: Handle Merge Conflicts (Netflix Style)

### 🎬 **Scenario**: Another engineer modified the same file

```powershell
# Switch to develop and create conflicting changes
git checkout develop
echo "class RecommendationEngine:" > recommendation.py
echo "    def get_recommendations(self, user_id):" >> recommendation.py
echo "        # Different implementation" >> recommendation.py
echo "        return ['Squid Game', 'Ozark']" >> recommendation.py

git add recommendation.py
git commit -m "feat: alternative recommendation approach"
```

### 🎯 **Task 2.1**: Resolve Conflicts Like a Pro
```powershell
# Attempt merge (will conflict)
git checkout feature/recommendation-algorithm
git merge develop

# Resolve conflict manually
# Edit recommendation.py to combine both approaches
```

### 💡 **Netflix Solution Pattern**
```python
class RecommendationEngine:
    def suggest_movies(self, user_id):
        # Netflix magic happens here
        return ['Stranger Things', 'The Crown']
    
    def trending_content(self):
        return ['Wednesday', 'Glass Onion']
    
    def get_recommendations(self, user_id):
        # Combined approach - best of both worlds
        personal = self.suggest_movies(user_id)
        trending = self.trending_content()
        return personal + trending
```

```powershell
# Complete the merge
git add recommendation.py
git commit -m "merge: combine recommendation strategies"
```

### ✅ **Validation 2.1**
```powershell
# Verify clean merge
git log --oneline --graph
# Should show clean merge history
```

---

## 🎯 Challenge 3: Disaster Recovery (The Netflix Way)

### 🎬 **Scenario**: Oops! Accidental force push to main

```powershell
# Simulate disaster
git checkout main
git reset --hard HEAD~2
git push --force-with-lease origin main
```

### 🚨 **DISASTER ALERT**: Production is broken!

### 🎯 **Task 3.1**: Emergency Recovery
```powershell
# Find the lost commits
git reflog

# Recover using reflog
git reset --hard HEAD@{2}

# Verify recovery
git log --oneline
```

### 🎯 **Task 3.2**: Implement Netflix Safety Measures
```powershell
# Create pre-push hook
mkdir .git/hooks
echo '#!/bin/bash' > .git/hooks/pre-push
echo 'echo "🚨 NETFLIX SAFETY: Pushing to $(git branch --show-current)"' >> .git/hooks/pre-push
echo 'read -p "Are you sure? (y/N): " confirm' >> .git/hooks/pre-push
echo '[[ $confirm == [yY] ]] || exit 1' >> .git/hooks/pre-push

chmod +x .git/hooks/pre-push
```

### ✅ **Validation 3.1**
```powershell
# Test safety hook
git push origin main
# Should prompt for confirmation
```

---

## 🎯 Challenge 4: Netflix Automation

### 🎬 **Scenario**: Automate the Netflix workflow

### 🎯 **Task 4.1**: Create Netflix-Style Aliases
```powershell
# Add to .gitconfig
git config --global alias.netflix-feature '!f() { git checkout -b feature/$1; }; f'
git config --global alias.netflix-hotfix '!f() { git checkout -b hotfix/$1; }; f'
git config --global alias.netflix-release '!f() { git checkout -b release/$1; }; f'

# Test aliases
git netflix-feature user-profiles
```

### 🎯 **Task 4.2**: Implement Commit Message Standards
```powershell
# Create commit message template
echo "# Netflix Commit Template" > .gitmessage
echo "# feat: new feature" >> .gitmessage
echo "# fix: bug fix" >> .gitmessage
echo "# docs: documentation" >> .gitmessage
echo "# style: formatting" >> .gitmessage
echo "# refactor: code restructure" >> .gitmessage
echo "# test: adding tests" >> .gitmessage
echo "# chore: maintenance" >> .gitmessage

git config commit.template .gitmessage
```

### ✅ **Validation 4.1**
```powershell
# Test commit template
git commit
# Should show template
```

---

## 🎮 Bonus Challenges

### 🏆 **Bonus 1**: Netflix Release Process
```powershell
# Create release branch
git netflix-release v2.1.0

# Prepare release
echo "version = '2.1.0'" > version.py
git add version.py
git commit -m "chore: bump version to 2.1.0"

# Merge to main and develop
git checkout main
git merge release/v2.1.0
git tag v2.1.0

git checkout develop
git merge release/v2.1.0
```

### 🏆 **Bonus 2**: Emergency Hotfix
```powershell
# Critical bug in production!
git checkout main
git netflix-hotfix critical-security-patch

# Fix the issue
echo "# Security patch applied" >> security.md
git add security.md
git commit -m "fix: critical security vulnerability"

# Deploy hotfix
git checkout main
git merge hotfix/critical-security-patch
git tag v2.1.1
```

---

## 📊 Lab Assessment

### ✅ **Success Criteria**
- [ ] Implemented Netflix branching strategy
- [ ] Resolved merge conflicts cleanly
- [ ] Recovered from git disaster
- [ ] Created automation hooks
- [ ] Followed commit conventions

### 🎯 **Skill Validation**
```powershell
# Run validation script
./validate-netflix-workflow.bat

Expected Output:
✅ Branch strategy implemented
✅ Merge conflicts resolved
✅ Disaster recovery successful
✅ Automation hooks active
✅ Commit standards followed

🏆 Netflix Git Mastery: ACHIEVED!
```

---

## 🎓 What You Learned

### 🧠 **Key Concepts**
- **Branching Strategy**: Netflix's production-ready approach
- **Conflict Resolution**: Professional merge techniques
- **Disaster Recovery**: Using reflog and reset safely
- **Automation**: Hooks and aliases for efficiency
- **Standards**: Consistent commit messaging

### 💼 **Career Impact**
- **Skill Level**: Git Expert
- **Industry Standard**: Netflix-grade workflows
- **Salary Impact**: +$15k (Git mastery premium)
- **Interview Ready**: Handle any Git question

### 🎯 **Next Steps**
- 🔄 **Lab 2**: [Code Review Game](./02-code-review-game.md)
- 🧪 **Lab 3**: [Test Pyramid Builder](./03-test-pyramid.md)
- 🚀 **Advanced**: [Enterprise Git Strategies](../enterprise-devops/01-enterprise-git.md)

---

## 🏆 Achievement Unlocked!

```
🎬 NETFLIX GIT MASTER
├── 🎯 Completed: Netflix Workflow Lab
├── 💪 Skills: Professional Git workflows
├── 🏆 XP Earned: 100 points
├── 🎖️ Badge: Git Ninja
└── 🚀 Next: Code Review Mastery
```

**🎉 Congratulations! You now handle Git like a Netflix engineer!**

---

## 📚 Additional Resources

- 📖 [Netflix Tech Blog: Git at Scale](https://netflixtechblog.com)
- 🎥 [Video: Netflix Engineering Practices](https://youtube.com/netflix)
- 📊 [Git Flow vs Netflix Flow](https://www.atlassian.com/git/tutorials)
- 🛠️ [Advanced Git Techniques](https://git-scm.com/docs)

**Ready for the next challenge? Let's master code reviews! 🚀**